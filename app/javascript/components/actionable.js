import Vue from 'vue'
import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './actionable.html'
import StatementChangeSummary from './statement_change_summary'

Vue.component('StatementChangeSummary', StatementChangeSummary)

export default template({
  data () { return {
    finished: false,
    updateError: null,
  } },
  props: ['statement', 'page', 'country'],
  created: function () {
    if (this.statement.bulk_update) {
      // To avoid lots of statements being actioned in parallel, which
      // is bad API usage etiquette, we don't automatically action
      // this statement if it appears to come from a bulk update:
      this.statement.bulk_update = false
      return;
    }
    this.statement.bulk_update = false
    if (['verifiable', 'reconcilable', 'manually_actionable'].indexOf(this.statement.previousType) !== -1) {
      this.updatePositionHeld()
    }
  },
  methods: {
    logger: function (data) {
      this.$parent.$emit('log', data)
    },
    updatePositionHeld: function () {
      var personItem = this.statement.person_item,
          item = wikidataClient.setLogger(this.logger).item(personItem),
          references = {},
          qualifiers = {},
          updateData = {
            property: wikidataClient.getPropertyID('position held'),
            object: this.page.position_held_item,
            references: references,
            qualifiers: qualifiers,
          }, that = this;

      if (this.statement.statement_uuid) {
        // Make sure there's a $ in the claim ID separating the item
        // ID from the UUID, otherwise we get invalid GUID errors.
        updateData.statement = this.statement.statement_uuid.replace(/^(Q\d+)[^\d]/, '$1$');
      }

      references[wikidataClient.getReferencePropertyID(this.page.reference_url)] = {
        value: this.page.reference_url, type: 'string'
      }

      references[wikidataClient.getPropertyID('reference retrieved')] = {
        value: this.statement.verified_on, type: 'time'
      }

      // TODO: Make sure the FIXME below has been corrected before enabling
      // this code again.
      //
      // if (this.page.reference_url_title) {
      //   references[wikidataClient.getPropertyID('title')] = {
      //     value: {
      //       text: this.page.reference_url_title,
      //       // FIXME: This needs to be set dynamically depending on the
      //       // language of the page, but we can't just use
      //       // page.reference_url_language, because that's a Q value, not a
      //       // plain string.
      //       language: 'en',
      //     },
      //     type: 'monolingualtext'
      //   };
      // }

      // if (this.page.reference_url_language) {
      //   references[wikidataClient.getPropertyID('language of work or name')] = {
      //     value: getItemValue(this.page.reference_url_language),
      //     type: 'wikibase-entityid'
      //   };
      // }

      if (!this.page.executive_position && this.statement.parliamentary_group_item) {
        qualifiers[wikidataClient.getPropertyID('parliamentary group')] =
          this.statement.parliamentary_group_item;
      }
      if (!this.page.executive_position && this.statement.electoral_district_item) {
        qualifiers[wikidataClient.getPropertyID('electoral district')] =
          this.statement.electoral_district_item;
      }
      if (this.statement.parliamentary_term_item) {
        qualifiers[wikidataClient.getPropertyID('parliamentary term')] =
          this.statement.parliamentary_term_item;
      }

      this.$parent.$emit('loading', 'Saving')

      item.latestRevision().then(function(lastRevisionID) {
        return item.updateOrCreateClaim(lastRevisionID, updateData);
      }).then(function (result) {
        console.log('updating the statement succeeded:', result);
        that.finished = true;
        that.updateError = null;

        that.$parent.$emit('statement-update', () => {
          return Axios.get(
            ENV.url + '/statements/' + that.statement.transaction_id + '.json',
            { params: { force_type: 'done' } }
          )
        })
      }).catch(function (error) {
        console.log('updating the statement failed...', error)

        that.finished = true
        that.updateError = error.message

        that.$parent.$emit('error')
      });
    },
    reportStatementError: function () {
      this.$parent.$emit('statement-update', () => {
        return Axios.get(
          ENV.url + '/statements/' + this.statement.transaction_id + '.json',
          { params: {
            force_type: 'manually_actionable',
            error_message: this.updateError
          } }
        )
      })
    }
  }
})
