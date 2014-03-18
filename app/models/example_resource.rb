class ExampleResource
  include Tripod::Resource

  field :rdfs_label, RDF::RDFS.label
  field :title, RDF::DC.title
  field :skos_literal_form, RDF::SKOSXL.literalForm

  field :name_official, RDF::URI.new("http://www.fao.org/countryprofiles/geoinfo/geopolitical/resource/nameOfficial"), multivalued: true

  def label
    label = rdfs_label || title || skos_literal_form || name_official

    labels = if label.class == Array
               label.empty? ? ["Sample Resource"] : label
             else
               [label]
             end
    labels
  end
end
