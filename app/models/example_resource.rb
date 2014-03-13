class ExampleResource
  include Tripod::Resource

  field :rdfs_label, RDF::RDFS.label
  field :title, RDF::DC.title
  field :skos_literal_form, RDF::SKOSXL.literalForm

  def label
    rdfs_label || title || skos_literal_form || 'Sample Resource'
  end
end
