RSpec.shared_context('id-mapping-store default setup') do
  def stub_id_mapping_store(scheme_id:, identifier:)
    scheme_data = {
      'results' => [
        {
          'id' => 1,
          'name' => 'wikidata-persons'
        },
        {
          'id' => 2,
          'name' => 'wikidata-memberships'
        },
        {
          'id' => 3,
          'name' => 'wikidata-organizations'
        },
        {
          'id' => 4,
          'name' => 'ms-uuid-persons'
        },
        {
          'id' => 5,
          'name' => 'ms-uuid-memberships'
        },
        {
          'id' => 6,
          'name' => 'ms-uuid-organizations'
        },
        {
          'id' => 7,
          'name' => 'facebook-persons'
        }
      ]
    }
    id_mapping_store_base_url = ENV.fetch(
      'ID_MAPPING_STORE_BASE_URL', 'https://id-mapping-store.mysociety.org'
    )
    stub_request(:get, "#{id_mapping_store_base_url}/scheme")
      .to_return(status: 200, body: JSON.pretty_generate(scheme_data))
    stub_request(:get, "#{id_mapping_store_base_url}/identifier/#{scheme_id}/#{identifier}")
        .to_return(status: 404, body: '')
  end
end
