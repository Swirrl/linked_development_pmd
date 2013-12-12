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
    #ds.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    #ds.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    ds.save!
  end

  desc 'Create dataset metadata for eldis/r4d'
  task create: :environment do
    replace_dataset_metadata("http://linked-development.org/data/eldis", "http://linked-development.org/graph/eldis", 'Eldis Data', 'Eldis Data comment', 'markdown description goes here')
    replace_dataset_metadata("http://linked-development.org/data/r4d", "http://linked-development.org/graph/r4d", 'R4D Data', 'R4D Data comment', 'markdown description goes here')
  end

  
end
