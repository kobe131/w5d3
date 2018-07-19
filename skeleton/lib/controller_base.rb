require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params={})
    @req = req 
    @res = res
    @params = params
    @session = Session.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    session.store_session(@res)
    raise "You try to double redirect" if already_built_response?
    @res.status = 302
    @res['Location'] = url
    @already_built_response = true 
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    session.store_session(@res)
    raise "You try to double render" if already_built_response?
    @res.write(content)
    @res['Content-Type'] = content_type 
    @already_built_response = true 
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_path = File.dirname(__FILE__)
    dir_path = dir_path.truncate(dir_path.length-4, omission: "")
    class_name = self.class.to_s.underscore
    path = File.join(dir_path, "views",class_name, "#{template_name}") + ".html.erb"
    code = File.read(path)
    erb_template = ERB.new(code).result(binding)
    render_content(erb_template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    unless already_built_response?
      render(name.to_sym)
    end
  end
end

