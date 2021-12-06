class PagesController < ApplicationController
  def home
    # TODO: reduce image size --> image uploader
    Page::NAMES.each do |page_name|
      instance_variable_set "@#{page_name}", page_content_retriever(page_name)
      instance_variable_set "@#{page_name}_images", page_image_retriever(page_name)
    end
  end

  def contact
    @main_content = Content.find_by(page: 'contact')
  end

  private

  def page_content_retriever(page)
    Content.find_by(page: page)
  end

  def page_image_retriever(page)
    Image.where(page: page)
  end
end
