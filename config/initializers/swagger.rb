unless Rails.env.test?
  Swagger::Docs::Config.base_api_controller = ActionController::API

  Swagger::Docs::Config.register_apis({
    "1.0" => {
      # the output location where your .json files are written to
      :api_file_path => "public/apidocs",
      # the URL base path to your API
      :base_path => APP_CONFIG.api_base_path.gsub('api/v1',''),
      # if you want to delete all .json files at each generation
      :clean_directory => false,
      # add custom attributes to api-docs
      :attributes => {
        :info => {
          "title" => "Flyingflea API Documentation",
          "termsOfServiceUrl" => "https://theflyingflea.com/infos/terms",
        }
      }
    }
  })

  class Swagger::Docs::Config
    def self.transform_path(path, api_version)
      "apidocs/#{path}"
    end
  end

  SwaggerUiEngine.configure do |config|
    config.swagger_url = '/apidocs/api-docs.json'
  end
end
