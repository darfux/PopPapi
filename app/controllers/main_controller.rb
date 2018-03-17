class MainController < ApplicationController
  def index
    @check_data = YAML.load_file("checker/data.yaml")
  end

  def repeat
    id = params["id"]
    doc = File.read("checker/tmp/test/#{id}.html")
    render plain: doc
  end
end
