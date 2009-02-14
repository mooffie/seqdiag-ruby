#!/usr/bin/ruby

require '../../seqdiag'

client = Model.new('client', 'Client')
v = Model.new('v', '$view', :needs_new => true)
h = Model.new('h', 'Handlers', :needs_new => true)
q = Model.new('q', '$view->query', :needs_new => true, :flags => 'rx')
d = Model.new('d', '$view->display_handler', :needs_new => true)
s = Model.new('s', '$view->style_plugin', :needs_new => true)
r = Model.new('r', '$view->style_plugin->row_plugin', :needs_new => true)

start_with(client) {

  note "You get a view by calling\nviews_get_view('view_name')", :right_of => v
  v.new

  v.set_display('$display_id') {
    note "Display handlers are\ncreated by init_display()", :right_of => d
    d.new
    line "$this->current_display = $display_id"
  }

  #
  # Build query
  #
  v.build {
    q.new(' $this->base_table ')
    note "Handlers for fields/filters/etc\nare created by init_hanlders()", :right_of => h

    h.new
    h.pre_query(:cond => '* [all handlers]')

    h.query(:cond => '* [relationship hanlders]') {
      q.add_relationship
    }
    h.query(:cond => '* [filter hanlders]') {
      q.add_where
    }
    h.query(:cond => '* [argument hanlders]', :ids => [8]) {
      q.add_where
    }

    line '_'
    note "Only simplest case shown.\nSee separate diagram for more.", :attach_to => 8
    s.new {
      r.new
    }
    line '_'

    note "If $this->style_plugin->uses_fields()", :attach_to => 2
    h.query(:cond => '* [field hanlders]', :ids => [2]) {
      q.add_field
    }
    h.query(:cond => '* [sort hanlders]') {
      q.add_orderby
    }

    ##EXTRA
    #v:d.query()
    #d:q.whatever()
    #v:s.query()
    #s:q.whatever()
    ##END

    q.query(:return => "$this->build_info['query']")
  }

  v.execute() {
    line "db_query( $this->build_info['query'] )"
    line '$this->result = ...data...'
  }

  #
  # Rendering
  #
  v.render(:return => '$output') {
    h.pre_render(:cond => '* [field handlers]')
    d.render(:return => '$output') {
      line ''
      line '... render "decorations", e.g. header  ...'
      note "The style's render() is invoked\nindirectly, through the display's template\npreprocess function.", :attach_to => 4, :right_of => s
      s.render(:return => '$more_output', :ids => [4]) {
        line ''
        line ' ... render the heart of the data ...'
        line ''
        r.render(:return => '$rows', :cond => '* [all rows]')
        line ''
      }
    }
  }
  line 'print $output'
  line ''

  #
  # Executing a display
  #
  note "execute_display(), below, is\nlike render() but it also\n\"glues\" the output to Drupal;\ne.g. by setting a page title."
  v.execute_display(:return => '$output') {
    line '// call hook_views_pre_view()'
    line '// of each module'
    line ''
    d.pre_execute() {
      line '$this->view->set_items_per_page(...)'
      line '...'
    }
    d.execute(:return => '$output') {
      note "call $this->view->build(), if not\ncalled already"
      line "drupal_set_title($build_info['title'])"
      line "$this->view->get_breadcrumb(TRUE)"
      note "And return the output of\n$this->view->render(),\ndirectly or indirecly."
    }
  }
  line 'print $output'

}
