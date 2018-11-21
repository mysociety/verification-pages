<template>
  <div id="verification-tool">
    <div v-if="loaded" class="verification-tool__controls">
      <sort-control
        v-bind:options="sortOptions"
        v-bind:selectedOption="sortBy"
        v-on:sort="sortStatements"
      ></sort-control>
    </div>
    <div v-if="loaded && statements.length === 0" class="verification-tool__blank-slate">
      No statements
    </div>
    <div v-if="loaded && statements.length > 0">
      <table class="verification-tool__table">
        <thead>
          <tr>
            <th>Confirmed?</th>
            <th>Subject</th>
            <th>District</th>
            <th>Parliamentary group</th>
            <th></th>
          </tr>
        </thead>
        <Statement
          v-for="statement in statements"
          :key="statement.transaction_id"
          :statement="statement"
          :page="page"
          :country="country"
          @reference-url-change="onChangeReferenceURL"
        ></Statement>
      </table>
    </div>
    <div v-if="!loaded" class="verification-tool__blank-slate">
      <span class="verification-tool__spinner">
          <span></span>
          <span></span>
          <span></span>
      </span>
      Loading up-to-date statements… (this might take a while)
    </div>
  </div>
</template>

<script>
/* global localStorage */
import Vue from 'vue'
import ENV from './env'
import Axios from 'axios'
import wikidataClient from './wikiapi'
import { parseFullName } from 'parse-full-name'

import statementComponent from './components/statement'
import SortControl from './components/sort_control'

Vue.component('Statement', statementComponent)
Vue.component('sort-control', SortControl)

export default {
  data () {
    return {
      loaded: false,
      statements: [],
      sortBy: 'lastName',
      sortOptions: [
        ['lastName', 'Last name'],
        ['firstName', 'First name'],
        ['district', 'District'],
        ['parliamentaryGroup', 'Parliamentary group'],
        ['type', 'Type']
      ],
      page: null
    }
  },
  created: function () {
    this.loadStatements()
    this.$on('statement-update', (requestFunction, cb) => {
      requestFunction().then(response => {
        response.data.statements.forEach(function (newStatement) {
          var index = this.statements.findIndex(s => {
            return s.transaction_id === newStatement.transaction_id
          })
          var previousType = this.statements[index].type
          newStatement.previousType = previousType
          this.statements.splice(index, 1, newStatement)
        }, this)
      }).then(cb)
    })
    this.$on('statements-loaded', () => {
      this.$nextTick(function () {
        var hash = window.location.hash
        if (hash) {
          this.$emit('scroll-to-fragment', hash)
        }
        const localStorageReferenceURL = localStorage.getItem(this.localStorageKey)
        if (localStorageReferenceURL) {
          this.page.reference_url = localStorageReferenceURL
        }
      })
    })
    this.$on('find-matching-statements', (data, cb) => {
      const {resourceType, statement, nameAttr, itemAttr, newItem} = data
      if (resourceType === 'person') {
        cb(null, 0)
        return
      }
      let otherMatching = this.statements.filter(s => {
        return nameAttr && itemAttr && statement[nameAttr] &&
          (s[nameAttr] === statement[nameAttr]) &&
          (s[itemAttr] !== newItem) &&
          (s.transaction_id !== statement.transaction_id)
      })
      let otherMatchingUnreconciled = otherMatching.filter(s => !s[itemAttr])
      cb(null, {
        otherMatching: otherMatching.length,
        otherMatchingUnreconciled: otherMatchingUnreconciled.length
      })
    })
    this.$on('scroll-to-fragment', (fragment) => {
      let selector = fragment.replace(/:/g, '\\:')
      let statementRow = document.querySelector(selector)
      if (statementRow) {
        let headerHeight = document.querySelector('.verification-tool__table th').offsetHeight
        statementRow.scrollIntoView()
        window.scrollBy(0, -headerHeight)
        statementRow.className += ' targetted'
      }
    })
  },
  methods: {
    loadStatements: function () {
      Axios.get(ENV.url + '/statements.json', {
        params: { title: wikidataClient.page, classifier: this.classifierVersion }
      }).then(response => {
        this.statements = response.data.statements
        this.sortStatements(this.sortBy)
        this.page = response.data.page
        this.country = response.data.country
      }).then(() => {
        this.loaded = true
        this.$emit('statements-loaded')
      })
    },
    countStatementsOfType: function (type) {
      if (type !== 'all') {
        return this.statements.filter(s => s.type === type).length
      } else {
        return this.statements.length
      }
    },
    sortStatements: function (sortBy) {
      this.statements = this.statements.sort((a, b) => {
        const typeOrder = [
          'verifiable',
          'reconcilable',
          'actionable',
          'manually_actionable',
          'reverted',
          'unverifiable',
          'done'
        ]
        const namesA = parseFullName(a.person_name)
        const namesB = parseFullName(b.person_name)
        const statementA = Object.assign({}, a, {
          firstName: namesA.first,
          lastName: namesA.last,
          typeSort: typeOrder.indexOf(a.type)
        })
        const statementB = Object.assign({}, b, {
          firstName: namesB.first,
          lastName: namesB.last,
          typeSort: typeOrder.indexOf(b.type)
        })
        let sortFields
        switch (sortBy) {
          case 'lastName':
            sortFields = ['lastName', 'firstName']
            break
          case 'firstName':
            sortFields = ['firstName', 'lastName']
            break
          case 'parliamentaryGroup':
            sortFields = ['parliamentary_group_name', 'lastName', 'firstName']
            break
          case 'district':
            sortFields = ['electoral_district_name', 'lastName', 'firstName']
            break
          case 'type':
            sortFields = ['typeSort', 'lastName', 'firstName']
            break
        }
        const stringA = sortFields.map(field => statementA[field]).join(' ')
        const stringB = sortFields.map(field => statementB[field]).join(' ')
        return stringA.localeCompare(stringB)
      })
    },
    onChangeReferenceURL: function (newReferenceURL) {
      this.page.reference_url = newReferenceURL
      localStorage.setItem(this.localStorageKey, newReferenceURL)
    }
  },
  computed: {
    localStorageKey: function () {
      return wikidataClient.page + '.reference_url'
    },
    classifierVersion: function () {
      return localStorage.getItem('classifierVersion')
    }
  }
}
</script>

<style lang="scss">
$color_mid_blue: #2980b9;
$color_pale_blue: #e2f0f9;
$color_mid_orange: #ec920c;
$color_pale_orange: #f9f3e2;
$color_mid_red: #b92929;
$color_pale_red: #f9e2e2;
$color_mid_green: #50b929;
$color_pale_green: #e6f9e2;
$color_mid_grey: #999;
$color_pale_grey: #eee;

$color_wikipedia_bluelink: #0645ad;
$color_wikipedia_redlink: #ba0000;

@mixin clearfix() {
    zoom: 1;

    &:before,
    &:after {
        content: "";
        display: table;
    }

    &:after {
        clear: both;
    }
}

.verification-tool__table,
.verification-tool__blank-slate {
    margin-top: 1em;
    border: 1px solid #ccc;
}

.verification-tool__table {
    width: 100%;
    border-spacing: 0;

    td {
        padding: 1em;
        vertical-align: top;
    }

    th {
        position: -webkit-sticky;
        position: sticky;
        top: 0;
        background: transparent linear-gradient(to bottom, #fff 66%, transparent);

        padding: 1em;
        text-align: inherit;
    }

    thead {
        & + tbody tr:first-child td {
            padding-top: 0;
        }
    }

    h3 {
        .mw-ui-button {
            font-size: 0.8em;
            margin: 0 0.5em;
        }

        input {
            font-weight: inherit;
            font-size: inherit;
        }

        .language-chooser {
            width: 3em;
            text-align: right;
        }
    }

    tr:target, .targetted {
        animation: background-yellow-to-white 5s 1;
    }
}

.verification-tool__blank-slate {
    text-align: center;
    padding: 3em;
}

.verification-tool__spinner {
    display: inline-block;
    margin: 0 0.5em;
    height: 1em;
    vertical-align: -0.1em;

    span {
        display: inline-block;
        height: 100%;
        width: 5px;
        background: #000;
        animation: stretchdelay 1s infinite ease-in-out;

        @for $i from 1 through 3 {
            &:nth-child(#{$i}) {
                animation-delay: (-1s + ($i / 10));
            }
        }
    }
}

@keyframes stretchdelay {
  0%, 40%, 100% {
    transform: scaleY(0.4);
  }
  20% {
    transform: scaleY(1.0);
  }
}

@keyframes background-yellow-to-white {
  0%, 50% {
    background: #ffffcc;
  }
  100% {
    background: #ffffff;
  }
}

.verification-tool__table__cell-link {
    padding: 0.5em;
}

.verification-tool__table__cell--narrow {
    width: 0;
}

.verification-tool__table__cell--verification-status {
    .edit-value {
        font-size: 0.8em;
        vertical-align: middle;
    }
    .verification-status-character {
        font-size: 2em;
        vertical-align: middle;
    }
}

.verification-tool__search-results {
    list-style: none;
    margin: 0;

    li {
        padding-top: 1em;
        margin-top: 1em;
        border-top: 1px solid rgba(#000, 0.1);
        display: flex;
        align-items: center;

        & > button {
            flex: 0 0 auto;
            margin-right: 1em;
        }

        & > div {
            flex: 1 1 auto;
        }
    }

    p.description {
        margin: 0;
    }

    .searchmatch {
        background-color: rgba(#ff0, 0.7);
    }
}

.verification-tool__controls {
    @include clearfix();
    margin: 0 -0.5em -0.5em -0.5em;

    // Compensate for vertical padding on buttons.
    .mw-ui-button {
        margin-top: -0.546875em;
        margin-bottom: -0.546875em;
    }
}

.verification-tool__controls__group {
    float: left;
    padding: 1em 0.5em;
}

.verification-tool__statement {
    .wikilink, .unreconciled-value {
        &:before {
            display: inline-block;
            content: "\21B3";
            margin-right: 0.5em;
        }
    }

    .unreconciled-value,
    .edit-value {
        cursor: pointer;

        &:hover, &:focus {
            text-decoration: underline;
        }
    }

    .unreconciled-value {
        color: $color_wikipedia_redlink;
    }

    .edit-value {
        color: $color_wikipedia_bluelink;
    }
}

.verification-tool__statement--verifiable {
    .unreconciled-value,
    .edit-value {
        color: $color_mid_grey;
        cursor: not-allowed;

        &:hover, &:focus {
            text-decoration: none;
        }
    }
}

.verification-tool__statement-controls {
    padding: 0.5em 1em;
    border-bottom: 3px solid $color_mid_blue;
    background: $color_pale_blue;
}

.verification-tool__statement-controls--error,
.verification-tool__statement-controls--unverifiable {
    border-color: $color_mid_red;
    background-color: $color_pale_red;
}

.verification-tool__statement-controls--done {
    border-color: $color_mid_green;
    background-color: $color_pale_green;
}

.verification-tool__statement-controls--manually_actionable {
    border-color: $color_mid_grey;
    background-color: $color_pale_grey;
}
</style>
