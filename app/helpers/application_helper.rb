module ApplicationHelper

  def cabi_menu_documentation
    overrides = {
                 :target => main_app.linked_development_api_docs_path,
                 :items => [{
                             title: "Linked Development API",
                             target: main_app.linked_development_api_docs_path,
                             highlight: nil
                            },
                            {
                             title: "Linked Data API",
                             target: publish_my_data.api_docs_path,
                             highlight: nil
                            }]
                }
    
    standard_menu_docs.merge overrides
  end
end
