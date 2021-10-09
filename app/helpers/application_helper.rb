module ApplicationHelper
  def show_content_actions(page)
    if signed_in?
      button_types(page)
    end
  end

  def upload_image_helper(page)
    link_to 'Neues Bild hochladen', new_image_path(page: page), class: 'waves-effect waves-light btn-small'
  end

  private

  def button_types(page)
    if page.nil?
      (link_to 'Neu', new_content_path, class: 'waves-effect waves-light btn-small')
    elsif page
      [
        (link_to 'Bearbeiten', edit_content_path(page), class: 'waves-effect waves-light btn-small'),
        (link_to 'Löschen', content_path(page), method: :delete, class: 'waves-effect waves-light btn-small', data: { confirm: 'Bist du sicher, dass du den Text löschen möchtest?'})
      ].join(' ').html_safe
    else
      []
    end
  end
end
