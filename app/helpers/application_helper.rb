module ApplicationHelper

  def cabi_menu_documentation
    overrides = {
       :target => main_app.linked_development_overview_docs_path,
       :title => "Documentation",
       :highlight => "doc_overview",
       :items => [
                  {
                   title: "Linked Development API",
                   target: main_app.linked_development_api_docs_path,
                   highlight: "linked_dev_docs"
                  },
                  {
                   title: "Linked Data API",
                   target: publish_my_data.api_docs_path,
                   highlight: "documentation"
                  }]
    }

    standard_menu_docs.merge overrides
   end

  def data_is_updating?
    LinkedDevelopmentPmd::RedirectWhenCrawling.update_in_progress?
  end
end
