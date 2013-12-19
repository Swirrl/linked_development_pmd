# re open dataset to update is_cube?
module PublishMyData
  Dataset.class_eval do
    def is_cube?
      return false
    end
  end
end