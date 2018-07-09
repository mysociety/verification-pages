import Vue from 'vue'
import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './actionable.html'
import StatementChangeSummary from './statement_change_summary'

Vue.component('StatementChangeSummary', StatementChangeSummary)

export default template({
  data () { return {
    updating: false,
    finished: false,
    updateError: null,
  } },
  props: ['statement', 'page', 'country'],
  created: function () {
    if (['verifiable', 'reconcilable'].indexOf(this.statement.previousType) !== -1) {
      this.updatePositionHeld()
    }
  },
  methods: {
    updatePositionHeld: function () {
      var personItem = this.statement.person_item,
          item = wikidataClient.item(personItem),
          references = {},
          qualifiers = {},
          updateData = {
            property: wikidataClient.getPropertyID('position held'),
            object: this.page.position_held_item,
            references: references,
            qualifiers: qualifiers,
          }, that = this;

      this.updating = true;

      if (this.statement.statement_uuid) {
        // Make sure there's a $ in the claim ID separating the item
        // ID from the UUID, otherwise we get invalid GUID errors.
        updateData.statement = this.statement.statement_uuid.replace(/^(Q\d+)[^\d]/, '$1$');
      }

      references[wikidataClient.getPropertyID('reference URL')] = {
        value: this.page.reference_url, type: 'string'
      }

      references[wikidataClient.getPropertyID('reference retrieved')] = {
        value: this.statement.verified_on, type: 'time'
      }

      if (this.statement.parliamentary_group_item) {
        qualifiers[wikidataClient.getPropertyID('parliamentary group')] =
          this.statement.parliamentary_group_item;
      }
      if (this.statement.electoral_district_item) {
        qualifiers[wikidataClient.getPropertyID('electoral district')] =
          this.statement.electoral_district_item;
      }
      if (this.statement.parliamentary_term_item) {
        qualifiers[wikidataClient.getPropertyID('parliamentary term')] =
          this.statement.parliamentary_term_item;
      }

      item.latestRevision().then(function(lastRevisionID) {
        return item.updateOrCreateClaim(lastRevisionID, updateData);
      }).then(function (result) {
        console.log('updating the statement succeeded:', result);
        that.updating = false;
        that.finished = true;
        that.updateError = null;

        that.$parent.$emit('statement-update', () => {
          return Axios.get(
            ENV.url + '/statements/' + that.statement.transaction_id + '.json',
            { params: { force_type: 'done' } }
          )
        })
      }).catch(function (error) {
        console.log('updating the statement failed...', error);
        that.updating = false;
        that.finished = true;
        that.updateError = error.message;
      });
    }
  }
})
