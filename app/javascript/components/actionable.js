import wikidataClient from '../wikiapi.js'
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
        updateData.statement = this.statement.statement_uuid;
      }

      if (this.statement.parliamentary_group_item) {
        qualifiers[wikidataClient.getPropertyID('parliamentary group')] =
          this.statement.parliamentary_group_item;
      }
      if (this.statement.electoral_district_item) {
        qualifiers[wikidataClient.getPropertyID('electoral district')] =
          this.statement.electoral_district_item;
      }

      item.latestRevision().then(function(lastRevisionID) {
        return item.updateOrCreateClaim(lastRevisionID, updateData);
      }).then(function (result) {
        console.log('updating the statement succeeded:', result);
        that.updating = false;
        that.finished = true;
        that.updateError = null;

        this.$parent.$emit('statement-update', () => {
          return Axios.get(ENV.url + '/statements/' + this.statement.transaction_id + '.json')
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
