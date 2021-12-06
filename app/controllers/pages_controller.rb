class PagesController < ApplicationController
  def home
    # TODO: reduce image size --> image uploader
    Page::NAMES.each do |page_name|
      instance_variable_set "@#{page_name}", page_content_retriever(page_name)
      instance_variable_set "@#{page_name}_images", page_image_retriever(page_name)
    end
  end

  def imprint
    @imprint = Content.find_by(page: 'imprint')
  end

  private

  def page_content_retriever(page)
    Content.find_by(page: page)
  end

  def page_image_retriever(page)
    Image.where(page: page)
  end
end
