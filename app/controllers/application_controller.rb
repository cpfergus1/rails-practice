class ApplicationController < ActionController::Base
  include SessionsHelper
  def hello
    render html: "¡Hola, mundo!"
  end
end
