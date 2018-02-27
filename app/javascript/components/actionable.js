import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './actionable.html'

export default template({
  data () { return {
    updating: false,
    finished: false,
    updateError: null,
  } },
  props: ['statement', 'page'],
  methods: {
    updatePositionHeld: function () {
      var personItem = this.statement.person_item,
          item = wikidataClient.item(personItem),
          qualifiers = {},
          updateData = {
            property: wikidataClient.getPropertyID('position held'),
            object: this.page.position_held_item,
            referenceURL: this.page.reference_url,
            qualifiers: qualifiers,
          }, that = this;

      this.updating = true;

      if (this.statement.statement_uuid) {
        // Make sure there's a $ in the claim ID separating the item
        // ID from the UUID, otherwise we get invalid GUID errors.
        updateData.statement = this.statement.statement_uuid.replace(/^(Q\d+)./, '$1$');
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
          return Axios.get(ENV.url + '/statements/' + that.statement.transaction_id + '.json')
        })
      }).catch(function (error) {
        console.log('updating the satement failed...', error);
        that.updating = false;
        that.finished = true;
        that.updateError = error;
      });
    }
  }
})
