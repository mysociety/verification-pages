/* global $, mw */
'use strict';

import Axios from 'axios'

function lowerCaseSnak(upperCase) {
  var parts = upperCase.split('$');
  return parts[0] + '$' + parts[1].toLowerCase();
}

function getItemValue(item) {
  return JSON.stringify(
    {'entity-type': 'item', 'numeric-id': Number(item.substring(1))});
}

function getQualifiersFromAPIClaims(apiClaims, property) {
  if (!apiClaims[property]) {
    return [];
  }
  return apiClaims[property][0].qualifiers;
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

function getReferenceSnaks(referenceURLProp, referenceURL) {
  var snaks = {};
  snaks[referenceURLProp] = [
    {
      snaktype: 'value',
      property: referenceURLProp,
      datavalue: {
        type: 'string',
        value: referenceURL,
      }
    }
  ];
  return JSON.stringify(snaks);
}

function getNewQualifiers(qualifiersFromAPI, wantedQualifiers) {
  var newQualifiers = $.extend({}, wantedQualifiers),
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

  my.alreadyHasReferenceURL = function(referencesFromAPI, wantedReference) {
    var i, j, values, referenceFromAPI;
    referencesFromAPI = referencesFromAPI || [];
    for (i = 0; i < referencesFromAPI.length; ++i) {
      referenceFromAPI = referencesFromAPI[i];
      values = referenceFromAPI.snaks[wikidata.referenceURLProperty] || [];
      for (j = 0; j < values.length; ++j) {
        if (values[j].datatype == 'string' && values[j].datavalue.value == wantedReference) {
          return true;
        }
      }
    }
    return false;
  };

  my.ajaxSetQualifier = function(qualifierDetails) {
    return wikidata.ajaxAPI(true, 'wbsetqualifier', {
            claim: qualifierDetails.statement,
            property: qualifierDetails.qualifierProperty,
            value: getItemValue(qualifierDetails.value),
            baseRevisionID: lastRevisionID,
            snaktype: 'value',
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
      return $.Deferred().resolve();
    }
  };

  my.createBareClaimDeferred = function(claimData) {
    // TODO the data we've been passed (indicating there wasn't an
    // existing statement to update) might be quite stale,
    // so we should really check that an appropriate claim hasn't
    // been created in the meantime.
    return wikidata.ajaxAPI(true, 'wbcreateclaim', {
      entity: item,
      snaktype: 'value',
      property: claimData.property,
      value: getItemValue(claimData.object),
      baserevid: lastRevisionID,
    }).then(function(data) {
        checkForError(data);
        lastRevisionID = data.pageinfo.lastrevid;
        return data.claim.id;
      }).fail(function(jqXHR, textStatus, errorThrown) {
        console.log("AJAX failure when trying to create a new claim:", jqXHR, textStatus, errorThrown);
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

      console.log('Looks good to update these qualifiers:', newQualifiers);
      return my.createQualifiers(newClaim, newQualifiers).then(function() {
        // Set a reference URL:
        if (my.alreadyHasReferenceURL(
          data.claims[newClaim.property][0].references,
          newClaim.referenceURL)) {
          return $.Deferred().resolve();
        } else {
          // We should set the referenceURL:
          return wikidata.ajaxAPI(true, 'wbsetreference', {
            statement: newClaim.statement,
            snaks: getReferenceSnaks(
              wikidata.referenceURLProperty,
              newClaim.referenceURL
            ),
            baserevid: lastRevisionID,
          });
        }
      });
    });
  };

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
        return my.updateClaim($.extend({}, claimData, {statement: statement}));
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
      var pageKey, revision = null, pages = data.query.pages;
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

var wikidata = function(spec) {
  var that = {};

  if (typeof mw === 'undefined') {
    window.mw = {
      config: {
        get: function(k) {
          return {
            wgServer: '//www.wikidata.org',
            wgServerName: 'www.wikidata.org'
          }[k]
        }
      }
    }
  }

  that.apiURL = 'https:' + mw.config.get('wgServer') + '/w/api.php';
  that.serverName = mw.config.get('wgServerName');

  that.ajaxAPIBasic = function (data) {
    console.log(data)
    return Axios.post(
      that.apiURL,
      {
        data: Object.assign({}, data, { format: 'json' }),
        responseType: 'json'
      }
    ).then(function(data) {
      return data.data;
    });
  };

  // that.tokenDeferred = that.ajaxAPIBasic({
  //   action: 'query',
  //   meta: 'tokens'
  // }).then(function(data) {
  //   return data.query.tokens.csrftoken;
  // });

  that.ajaxAPI = function(writeOperation, action, data) {
    var completeData = $.extend({}, data, {action: action});
    console.log(completeData)
    if (writeOperation) {
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

  that.referenceURLProperty = (function() {
    if (that.serverName == 'www.wikidata.org') {
      return 'P854'; // reference URL
    } else if (that.serverName == 'test.wikidata.org') {
      return 'P140'; // Return any old property that takes string values:
    } else {
      throw new Error('Running on an unknown Wikidata instance: ' + that.serverName);
    }
  })();

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
      allResults.fromWikidata = $.map(data.search, function(searchResult) {
        return {
          item: searchResult.id,
          label: searchResult.label,
          description: searchResult.description,
        }
      });
      return $.getJSON(
        'https://' + wikipediaToSearch + '.wikipedia.org/w/api.php?callback=?',
        {action: 'query', list: 'search', format: 'json', srsearch: name}
      );
    }).then(function(data) {
      var searchResults = $.map(data.query.search, function(result) {
        return {
          title: result.title,
          item: null,
          snippetHTML: result.snippet,
        }}),
          titles = $.map(searchResults, function(result) { return result.title });
      allResults.fromWikipedia = searchResults;
      // Get any Wikidata items associated with those titles from
      // sitelinks:
      return that.ajaxAPIBasic({
        action: 'wbgetentities',
        props: 'sitelinks',
        titles: titles.join('|'),
        sites: site,
      });
    }).then(function (sitelinksData) {
        var titleToWikidataItem = {};
        checkForError(sitelinksData);
      $.each(sitelinksData.entities, function (wikidataItem, sitelinkData) {
        // For titles that can't be found, you get back a string of
        // a negative number as the key. If it can be found, the key
        // is an Wikidata item ID.
        if (Number(wikidataItem) < 0) {
          return;
        }
        titleToWikidataItem[sitelinkData.sitelinks[site].title] = wikidataItem;
      });
      $.each(allResults.fromWikipedia, function(index, data) {
        if (titleToWikidataItem[data.title]) {
          data.item = titleToWikidataItem[data.title];
        }
      })
      return allResults;
    });
  });

  return that;
};

export default wikidata({})
