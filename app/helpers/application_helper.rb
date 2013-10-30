module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title }
  end

  def flash_translation(level)
    case level
    when :notice then "alert-info"
    when :success then "alert-success"
    when :error then "alert-error"
    when :alert then "alert-error"
    end
  end

	def current_url
		"#{request.protocol}#{request.host_with_port}#{request.fullpath}"
	end

	def full_url(path)
		"#{request.protocol}#{request.host_with_port}#{path}"
	end

	# Based on https://gist.github.com/1182136
  class BootstrapLinkRenderer < ::WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag :div, tag(:ul, html), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
    end

    def gap
      tag :li, link(super, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
    end
  end

  def page_navigation_links(pages)
    will_paginate(pages, :class => 'pagination', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&larr;'.html_safe, :next_label => '&rarr;'.html_safe)
  end

  def get_event_type_id(name)
    if name.present? && @event_types.present?
      index = @event_types.index{|x| x.name == name}
      if index.present?
        return @event_types[index].id
      end
    end
  end

	# from http://www.kensodev.com/2012/03/06/better-simple_format-for-rails-3-x-projects/
	# same as simple_format except it does not wrap all text in p tags
	def simple_format_no_tags(text, html_options = {}, options = {})
		text = '' if text.nil?
		text = smart_truncate(text, options[:truncate]) if options[:truncate].present?
		text = sanitize(text) unless options[:sanitize] == false
		text = text.to_str
		text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
#		text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
		text.html_safe
	end


  def barchart_no_overflow (left, color = '#fff')
    left = left.to_f;
    styles = ''
    if left > 87
      styles << 'right: ' + (100 - left).to_s + '%;'
      styles << 'color: ' + color + ' !important;'# text-shadow: 1px 0px #fff;'
    else
      styles << 'left: ' + left.to_s + '%;'
    end
    styles.html_safe
  end




end
