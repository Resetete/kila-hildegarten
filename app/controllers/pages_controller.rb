class PagesController < ApplicationController
  def home
    Page::NAMES.each do |page_name|
      instance_variable_set "@#{page_name}", page_content_retriever(page_name)
      instance_variable_set "@#{page_name}_images", page_image_retriever(page_name)
    end
  end

  def contact
    @contact = Content.find_by(page: 'contact')
  end

  def team
    @team_members = TeamMember.all
  end

  def parents
    @parents = Content.find_by(page: 'parents')
  end

  def photos
    @photos = page_image_retriever('photos')
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
