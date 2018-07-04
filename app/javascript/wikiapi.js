/* global $, mw */
'use strict';

import Axios from 'axios'
import jsonp from 'jsonp'

function lowerCaseSnak(upperCase) {
  var parts = upperCase.split('$');
  return parts[0] + '$' + parts[1].toLowerCase();
}

function getItemValue(item) {
  return {'entity-type': 'item', 'numeric-id': Number(item.substring(1))};
}

function getItemValueString(item) {
  return JSON.stringify(getItemValue(item));
}

function getQualifiersFromAPIClaims(apiClaims, property) {
  if (!apiClaims[property]) {
    return [];
  }
  return apiClaims[property][0].qualifiers;
}

function getReferencesFromAPIClaims(apiClaims, property) {
  if (!apiClaims[property]) {
    return [];
  }
  return apiClaims[property][0].references;
}

function getReferenceForURLFromAPIClaims (references, referenceURLProp, referenceURL) {
  if (!references || !referenceURL) return
  return references.find(function (r) {
    var snak = r.snaks[referenceURLProp].find(function (s) {
      return s.datatype === 'url' && s.datavalue.value === referenceURL.value
    })
    console.log(snak)
    return typeof snak !== 'undefined'
  })
}

function checkForError(data) {
  // Weirdly, errors like bad CSRF tokens still return success
  // rather than going to the fail handlers, so we use this even
  // on apparently successful AJAX calls.
  if (data.error) {
    throw new Error(
      'Error from the Wikidata API [' + data.error.code + '] ' +
      data.error.info + ': ' + data.error['*']
    );
  }
}

function buildReferenceSnaks (references) {
  var snaks = {}

  Object.keys(references).forEach(function (property) {
    var datavalue = references[property]
    if (!datavalue.value) return

    if (datavalue.type === 'time') {
      datavalue.value = {
        after: 0,
        before: 0,
        calendarmodel: 'http://www.wikidata.org/entity/Q1985727',
        precision: 11,
        time: datavalue.value,
        timezone: 0
      }
    }

    snaks[property] = [{
      snaktype: 'value',
      property: property,
      datavalue: datavalue
    }]
  })

  return JSON.stringify(snaks)
}

function getNewQualifiers(qualifiersFromAPI, wantedQualifiers) {
  var newQualifiers = Object.assign({}, wantedQualifiers),
      qualifiersToCheck = Object.keys(newQualifiers),
      existingQualifiersForProperty, newValue, i;
  if (qualifiersFromAPI) {
    for (i = 0; i < qualifiersToCheck.length; ++i) {
      existingQualifiersForProperty = qualifiersFromAPI[qualifiersToCheck[i]];
      if (!existingQualifiersForProperty) {
        continue;
      }
      if (existingQualifiersForProperty.length > 1) {
        throw new Error(
          'Multiple existing ' + qualifiersToCheck[i] + ' qualifiers found'
        );
      }
      if (existingQualifiersForProperty[0].snaktype != 'value') {
        throw new Error(
          'Unexpected snaktype ' + existingQualifiersForProperty[0].snaktype +
          ' found on the ' + qualifiersToCheck[i] + ' qualifier'
        );
      }
      if (existingQualifiersForProperty[0].datavalue.type != 'wikibase-entityid') {
        throw new Error(
          'Unexpected datavalue type ' + existingQualifiersForProperty[0].datavalue.type +
          ' found on the ' + qualifiersToCheck[i] + ' qualifier'
        );
      }
      newValue = newQualifiers[qualifiersToCheck[i]];
      if (existingQualifiersForProperty[0].datavalue.value.id == newValue) {
        delete newQualifiers[qualifiersToCheck[i]];
      } else {
        throw new Error(
          'The existing item for the ' + qualifiersToCheck[i] +
          ' qualifier was ' + existingQualifiersForProperty[0].datavalue.value.id +
          ' but we think it should be' + newValue
        );
      }
    }
  }
  return newQualifiers;
}

var wikidataItem = function(spec) {
  var that = {}, wikidata = spec.wikidata, item = spec.item, lastRevisionID = null,
      my = {};

  my.ajaxSetQualifier = function(qualifierDetails) {
    return wikidata.ajaxAPI(true, 'wbsetqualifier', {
            claim: qualifierDetails.statement,
            property: qualifierDetails.qualifierProperty,
            value: getItemValueString(qualifierDetails.value),
            baseRevisionID: lastRevisionID,
            snaktype: 'value',
            summary: wikidata.summary()
    }).then(function(data) {
      checkForError(data);
      lastRevisionID = data.pageinfo.lastrevid;
      return data;
    });
  };

  my.makeSetQualifierThenFunction = function(statementToCreate) {
    return function(data) {
      console.log('in \'then\' function for ' + statementToCreate + ' data was: ', data);
      checkForError(data);
      return my.ajaxSetQualifier(statementToCreate);
    };
  };

  my.createQualifiers = function(newClaim, newQualifiers) {
    var requestChain, i, statementsToCreate = Object.keys(newQualifiers).map(
      function (qualifierProperty) {
        return {
          statement: newClaim.statement,
          qualifierProperty: qualifierProperty,
          value: newQualifiers[qualifierProperty],
        };
      });

    console.log('There are ' + statementsToCreate.length + ' statements to create....');

    if (statementsToCreate.length > 0) {
      requestChain = my.ajaxSetQualifier(statementsToCreate[0]);
      for(i = 1; i < statementsToCreate.length; ++i) {
        requestChain = requestChain.then(
          my.makeSetQualifierThenFunction(statementsToCreate[i]));
      }
      return requestChain.then(function(data) {
        console.log('final data: ', data);
        checkForError(data);
      });
    } else {
      return Promise.resolve(null);
    }
  };

  my.createReferences = function (claims, data) {
    var referenceURLProp = wikidata.getPropertyID('reference URL')
    var referenceURL = data.references[referenceURLProp]

    var currentReference = getReferenceForURLFromAPIClaims(
      getReferencesFromAPIClaims(claims, data.property),
      referenceURLProp,
      referenceURL
    )

    console.log('There are ' + Object.keys(data.references).length + ' references to create....');

    if (Object.keys(data.references).length > 0) {
      var data = {
        statement: data.statement,
        snaks: buildReferenceSnaks(data.references),
        baserevid: lastRevisionID,
        summary: wikidata.summary()
      }

      if (currentReference) {
        data['reference'] = currentReference.hash
      }

      return wikidata.ajaxAPI(true, 'wbsetreference', data)
    } else {
      return Promise.resolve(null)
    }
  }

  my.createBareClaimDeferred = function(claimData) {
    // TODO the data we've been passed (indicating there wasn't an
    // existing statement to update) might be quite stale,
    // so we should really check that an appropriate claim hasn't
    // been created in the meantime.
    return wikidata.ajaxAPI(true, 'wbcreateclaim', {
      entity: item,
      snaktype: 'value',
      property: claimData.property,
      value: getItemValueString(claimData.object),
      baserevid: lastRevisionID,
      summary: wikidata.summary()
    }).then(function(data) {
        checkForError(data);
        lastRevisionID = data.pageinfo.lastrevid;
        return data.claim.id;
      }).catch(function(error) {
        console.log("AJAX failure when trying to create a new claim:", error);
      });
  };

  my.updateClaim = function(newClaim) {
    // First check that (currently) there are no qualifiers that
    // would be changed by updating the claim
    return wikidata.ajaxAPI(false, 'wbgetclaims', {
      entity: item,
      claim: newClaim.statement,
    }).then(function(data) {
        var i, requestChain, newQualifiers;
        checkForError(data);
        try {
          newQualifiers = getNewQualifiers(
            getQualifiersFromAPIClaims(data.claims, newClaim.property),
            newClaim.qualifiers
          );
        } catch(error) {
          throw new Error(
            'Problem checking existing qualifiers for statement ' +
            newClaim.statement + ' for relationship ' + item +
            ' <-- ' + newClaim.property + ' --> ' + newClaim.object + ": " +
            error.message
          );
        }

      console.log('Looks good to update these qualifiers:', newQualifiers)

      return my.createQualifiers(newClaim, newQualifiers).then(function (foo) {
        return my.createReferences(data.claims, newClaim)
      })
    })
  }

  that.updateOrCreateClaim = function(baseRevisionID, claimData) {
    lastRevisionID = baseRevisionID;
    if (claimData.statement) {
      return my.updateClaim(claimData);
    } else {
      // Then we need to create a new statement:
      return my.createBareClaimDeferred(claimData).then(function (statement) {
        if (!statement) {
          throw new Error("Creating the new statement failed");
        }
        return my.updateClaim(Object.assign({}, claimData, {statement: statement}));
      });
    }
  };

  that.latestRevision = function() {
    return wikidata.ajaxAPIBasic({
      action: 'query',
      prop: 'revisions',
      titles: item,
    }).then(function(data) {
      checkForError(data);
      var pageKey, revision = null,
          // FIXME: this is very weird; the response from the
          // mediawiki API doesn't include the .query, but when
          // calling the API directly it doesn't (!)
          pages = data.pages || data.query.pages;
      for (pageKey in pages) {
        if (pages.hasOwnProperty(pageKey)) {
          if (pages[pageKey].title == item) {
            return pages[pageKey].revisions[0].revid;
          }
        }
      }
           throw new Error('No revision found for item ' + item);
    });
  };

  return that;
};

function encodeURIParams(o) {
  // From a comment on: https://stackoverflow.com/a/18116302/223092
  return Object.entries(o).map(e => e.map(ee => encodeURIComponent(ee)).join('=')).join('&');
}

const jsonpPromise = function(url) {
  return new Promise(function (resolve, reject) {
    jsonp(url, null, function(err, data) {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    });
  });
}

var wikidata = function(spec) {
  var that = {};

  if (typeof mw === 'undefined') {
    that.useAPIProxy = true;
    that.apiURL = '/api-proxy'
    that.serverName = 'localhost'
    that.neverUseToken = true;
    that.user = 'ExampleUser';
    that.page = CURRENT_PAGE_TITLE;
  } else {
    that.useAPIProxy = false;
    that.apiURL = 'https:' + mw.config.get('wgServer') + '/w/api.php';
    that.serverName = mw.config.get('wgServerName');
    that.neverUseToken = false;
    that.user = mw.config.get('wgUserName');
    that.page = mw.config.get('wgRelevantPageName');
  }

  that.ajaxAPIBasic = function (data) {
    console.log(data)
    data = Object.assign({}, data, { format: 'json' })
    var params = new URLSearchParams()
    for (let [k, v] of Object.entries(data)) {
      params.append(k, v)
    }
    if (that.useAPIProxy) {
      params.append('action_name', data.action)
    }
    return Axios.post(
      that.apiURL, params, { responseType: 'json' }
    ).then(function(response) {
      return response.data;
    });
  };

  if (!that.neverUseToken) {
    that.tokenDeferred = that.ajaxAPIBasic({
      action: 'query',
      meta: 'tokens'
    }).then(function(data) {
      return data.query.tokens.csrftoken;
    });
  }

  that.ajaxAPI = function(writeOperation, action, data) {
    var completeData = Object.assign({}, data, {action: action});
    console.log(completeData)
    if (writeOperation && !that.neverUseToken) {
      return that.tokenDeferred.then(function (token) {
        completeData.token = token;
        return that.ajaxAPIBasic(completeData);
      });
    } else {
      return that.ajaxAPIBasic(completeData);
    }
  };

  that.item = function(itemID) {
    // Get the current revision ID for the item
    return wikidataItem({wikidata: that, item: itemID});
  };

  that.getPropertyID = function(propertyLabel) {
    return {
      'www.wikidata.org': {
        'reference URL': 'P854',
        'occupation': 'P106',
        'parliamentary group': 'P4100',
        'electoral district': 'P768',
        'position held': 'P39',
        'parliamentary term': 'P2937',
      },
      'test.wikidata.org': {
        'reference URL': 'P43659',
        'occupation': 'P70554',
        'parliamentary group': 'P70557',
        'electoral district': 'P70558',
        'position held': 'P39',
        'parliamentary term': 'P70901',
      },
      'localhost': {
        // For local development assume we're using test.wikidata for
        // the moment (FIXME: though it might be better to ask the
        // server for this information, since it must know which server
        // it's proxying to..)
        'reference URL': 'P43659',
        'occupation': 'P70554',
        'parliamentary group': 'P70557',
        'electoral district': 'P70558',
        'position held': 'P39',
        'parliamentary term': 'P70901',
      }
    }[that.serverName][propertyLabel];
  };

  that.getItemID = function(itemLabel) {
    return {
      'www.wikidata.org': {
        'politician': 'Q82955',
        'Canada': 'Q16',
      },
      'test.wikidata.org': {
        'politician': 'Q514',
        'Canada': 'Q620',
      },
      'localhost': {
        // For local development assume we're using test.wikidata for
        // the moment (FIXME: though it might be better to ask the
        // server for this information, since it must know which server
        // it's proxying to..)
        'politician': 'Q514',
        'Canada': 'Q620',
      }
    }[that.serverName][itemLabel];
  };

  function getPersonCreateData(label, description) {
    var data = {
      labels: {},
      descriptions: {},
    };
    data.labels[label.lang] = {
      language: label.lang,
      value: label.value,
    };
    data.descriptions[label.lang] = {
      language: description.lang,
      value: description.value,
    };
    data.claims = [
      {
        'mainsnak': {
          'snaktype': 'value',
          'property': that.getPropertyID('occupation'),
          'datavalue': {
            'value': getItemValue(that.getItemID('politician')),
            'type': 'wikibase-entityid'
          }
        },
        'type': 'statement',
        'rank': 'normal',
      },
    ];
    return JSON.stringify(data);
  }

  that.createPerson = function(personLabel, personDescription) {
    return that.ajaxAPI(true, 'wbeditentity', {
      new: 'item',
      data: getPersonCreateData(personLabel, personDescription),
      summary: this.summary()
    }).then(function (result) {
      return {
        item: result.entity.id,
        revisionID: result.entity.lastrevid,
      }
    });
  }

  that.search = (function(name, wikipediaToSearch, language) {
    var allResults = {}, site = wikipediaToSearch + 'wiki';
    return that.ajaxAPIBasic({
      action: 'wbsearchentities',
      search: name,
      language: language,
      limit: 20,
      type: 'item'
    }).then(function (data) {
      checkForError(data);
      allResults.fromWikidata = data.search.map(function(searchResult) {
        return {
          item: searchResult.id,
          label: searchResult.label,
          url: 'https://' + that.serverName + '/wiki/' + searchResult.id,
          description: searchResult.description,
        }
      });
      return jsonpPromise(
        'https://' + wikipediaToSearch + '.wikipedia.org/w/api.php?' +
          encodeURIParams({
            action: 'query', list: 'search', format: 'json', srsearch: name
          })
      );
    }).then(function(data) {
      var searchResults = data.query.search.map(function(result) {
        return {
          title: result.title,
          item: null,
          snippetHTML: result.snippet,
          wpURL: 'https://' + wikipediaToSearch + '.wikipedia.org/wiki/' +
            encodeURIComponent(result.title.replace(/ /, '_')),
        }}),
          titles = searchResults.map(function(result) { return result.title });
      allResults.fromWikipedia = searchResults;
      if (searchResults.length > 0) {
        // Get any Wikidata items associated with those titles from
        // sitelinks:
        return that.ajaxAPIBasic({
          action: 'wbgetentities',
          props: 'sitelinks',
          titles: titles.join('|'),
          sites: site,
        });
      } else {
        // Otherwise pass on empty results:
        return Promise.resolve({entities: []});
      }
    }).then(function (sitelinksData) {
      var titleToWikidataItem = {};
      checkForError(sitelinksData);
      for (let [wikidataItem, sitelinkData] of Object.entries(sitelinksData.entities)) {
        // For titles that can't be found, you get back a string of
        // a negative number as the key. If it can be found, the key
        // is an Wikidata item ID.
        if (Number(wikidataItem) < 0) {
          continue;
        }
        titleToWikidataItem[sitelinkData.sitelinks[site].title] = wikidataItem;
      }
      allResults.fromWikipedia.forEach(function(data, index) {
        var item = titleToWikidataItem[data.title];
        if (item) {
          data.item = item;
          data.wdURL = 'https://' + that.serverName + '/wiki/' + item;
        }
      })
      return allResults;
    });
  });

  that.summary = function() {
    return 'Edited with Verification Pages (' + this.page + ')'
  }

  return that;
};

export default wikidata({})
