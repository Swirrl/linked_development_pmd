require 'set'

class ExampleType
  include Tripod::Resource

  def self.graphs
    @@graphs ||= {
                    RDF::URI.new('http://linked-development.org/data/eldis') =>
                    RDF::URI.new('http://linked-development.org/graph/eldis'),
                    RDF::URI.new('http://linked-development.org/data/r4d') =>
                    RDF::URI.new('http://linked-development.org/graph/r4d')
                 }
    @@graphs
  end

  def self.blacklisted_classes
    @@exclude ||= Set.new(%w[AnnotationProperty Class DatatypeProperty Label ObjectProperty Ontology Restriction SymmetricProperty Thing TransitiveProperty])

    @@exclude
  end

  def self.find_types dataset
    dataset_graph = self.graphs[dataset.uri]

    # Select all the things which are classes (types)
    data = self.where("?foo a ?uri").graph(dataset_graph).resources.select { |r|
      r.valid?
    }

    # Strip out any type slugs we've blacklisted
    data.reject! { |t|
      self.blacklisted_classes.include?(t.type_slug)
    }

    # fold up the duplicates
    data = data.reduce([]) { |acc, i|
      is_duplicate = acc.select { |t|
        i.type_slug == t.type_slug && i.first_example == t.first_example
      }.any?

      acc << i unless is_duplicate
      acc
    }

    # alphabetize them by slug for display
    data.sort! { |this,other|
      this.type_slug <=> other.type_slug
    }
  end

  def first_example
    ExampleResource.where("?uri a <#{self.uri}> . FILTER(!isBlank(?uri))").first
  end

  # Hacky way to determine the label for the type
  def type_slug
    self.uri.to_s.split(/#|\//).last
  end
end
