module ApplicationHelper
  def show_content_actions(page)
    if signed_in?
      [
        (link_to 'new', new_content_path, class: 'waves-effect waves-light btn-small'),
        (link_to 'edit', edit_content_path(page), class: 'waves-effect waves-light btn-small')
      ].join(' ').html_safe
    end
  end
end
