namespace :dataset do

  def replace_dataset_metadata(uri, data_graph, title, comment, description_markdown)
    delete_graph("#{data_graph.to_s}/metadata") rescue puts "*** no metadata graph for #{data_graph.to_s} ***"

    ds = PublishMyData::Dataset.new(
                                    uri,
                                    "#{data_graph.to_s}/metadata"
                                    )

    ds.title = title
    ds.label = ds.title
    ds.comment = comment
    ds.issued = Time.now
    ds.description = description_markdown
    ds.contact_email = "mailto:todo@set-me-please.org"
    ds.license = "http://example.org/set-me-now"
    ds.publisher = "http://example.org/set-me-now/"

    ds.data_graph_uri = data_graph

    #ds.data_dump = "http://#{PublishMyData.local_domain}/dumps/#{DataDump.latest.basename}"
    ds.data_dump = "#{uri}/dump"
    ds.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    #ds.write_predicate(RDF::Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    ds.save!
  end

  desc 'Create dataset metadata for eldis/r4d'
  task create: :environment do
    replace_dataset_metadata("http://linked-development.org/data/eldis",
                             "http://linked-development.org/graph/eldis",
                             'Eldis Data',
                             'This dataset is drawn from ELDIS, an online information service hosted by the Institute for Development Studies. It provides up-to-date and diverse research on international development issues.',
<<-MARKDOWN)
The data in this dataset is updated every night via the [IDS Knowledge Services API](http://api.ids.ac.uk/).
    MARKDOWN

    replace_dataset_metadata("http://linked-development.org/data/r4d",
                             "http://linked-development.org/graph/r4d",
                             'R4D Data',
                             'This dataset is from Research for Development (R4D), it includes details of research publications and projects funded by the UK Department for International Development.',
<<-MARKDOWN)
The data in this dataset is updated every night from the [Department For International Development's](https://www.gov.uk/government/organisations/department-for-international-development) [Research for Development portal](http://r4d.dfid.gov.uk/).
    MARKDOWN
  end
end
