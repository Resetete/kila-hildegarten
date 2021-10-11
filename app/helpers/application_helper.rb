module ApplicationHelper
  def show_content_actions(page)
    if signed_in?
      button_types(page)
    end
  end

  def upload_image_helper(page)
    link_to 'Neues Bild hochladen', new_image_path(page: page), class: 'waves-effect waves-light btn-small'
  end

  def new_content_link_helper(page)
    link_to 'Neu', new_content_path(page: page), class: 'waves-effect waves-teal btn-flat red btn-small white-text'
  end

  # TODO: write a similar method for the content new page, wouldn't need the page selector array any more in the content model

  private

  def button_types(page)
    [
      (link_to 'Bearbeiten', edit_content_path(page), class: 'waves-effect waves-teal btn-flat red btn-small white-text'),
      (link_to 'Löschen', content_path(page), method: :delete, class: 'waves-effect waves-teal btn-flat red btn-small white-text', data: { confirm: 'Bist du sicher, dass du den Text löschen möchtest?'})
    ].join(' ').html_safe
  end
end
