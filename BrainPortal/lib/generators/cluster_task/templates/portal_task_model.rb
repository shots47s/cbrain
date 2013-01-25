<% if @_license_text.present? -%>

<%= @_license_text -%>
<% end -%>

# A subclass of CbrainTask to launch <%= class_name %>.
class <%= "CbrainTask::#{class_name}" %> < PortalTask

  Revision_info=CbrainFileRevision[__FILE__] #:nodoc:

  ################################################################
  # For full documentation on how to write CbrainTasks,
  # read the file doc/CbrainTask.txt in the subversion trunk.
  #
  # The basic API consists in three methods that you need to
  # override:
  #   self.default_launch_args(), before_form() and after_form().
  #
  # The advanced API consists in four more methods, needed only
  # for more complex cases:
  #
  # self.properties(), final_task_list(),
  # after_final_task_list_saved(tasklist)
  # and untouchable_params_attributes().
<% unless options[:advanced] -%>
  #
  # The advanced API is not included in this template since
  # you did not run the generator with the option --advanced.
<% end -%>
  #
  # Please remove all the comment blocks before committing
  # your code. Provide proper RDOC comments just before
  # each method if you want to document them, but note
  # that normally all normal API methods are #:nodoc: anyway.
  ################################################################



<% if options[:advanced] %>
  #***************************************************************
  #                  **** BASIC API ****
  #***************************************************************



<% end %>
  ################################################################
  # METHOD: self.default_launch_args()
  ################################################################
  # This method will be called before the form for your task is
  # rendered. It should return a hash table. This hash table will
  # be copied as-is into the task's params hash table.
  ################################################################

  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def self.default_launch_args #:nodoc:
    # Example: { :my_counter => 1, :output_file => "ABC.#{Time.now.to_i}" }
    {}
  end
  


  ################################################################
  # METHOD: before_form()
  ################################################################
  # This method will be called before the form for your task is
  # rendered. For new tasks, the task object's params hash table
  # will contain the list of IDs selected in the userfile manager:
  #
  #   params[:interface_userfile_ids]
  #
  # You can filter and validate the IDs here.
  # You're free to add as much supplemental information as
  # you want in the params hash table too, but remember that
  # the form will ONLY send you back (in after_form()) what
  # is also covered by input tags in the view file.
  #
  # You must not save your new task object here.
  #
  # The method should return a string to inform the user of any
  # changes or notifications, and raise an exception for any
  # fatal errors.
  #
  # This method is also called when editing an existing task's
  # parameters; you can detect when this happens because the
  # task object will not be new (it will return false for
  # the method new_record()).
  ################################################################
  
  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def before_form #:nodoc:
    params = self.params
    ids    = params[:interface_userfile_ids]
    #cb_error "Some error occurred."
    ""
  end



  ################################################################
  # METHOD: after_form()
  ################################################################
  # This method will be called after the form for your task has
  # been sunbmitted. The content of the task's attributes
  # (like :bourreau_id, :description, etc) will be filled in
  # by selection box already provided by the form. The params
  # hash table will contain the values of input tags contained
  # in the view (provided their variable names are properly
  # created with the to_la() methods). Note that any other
  # pieces of information stored in params() during before_form()
  # will be lost unless such input tags are present to preserve
  # them.
  #
  # You must not save your new task object here.
  #
  # The method should return a string to inform the user of any
  # changes or notifications, and raise an exception for any
  # fatal errors.
  #
  # This method is also called when editing an existing task's
  # parameters; you can detect when this happens because the
  # task object will not be new (it will return false for
  # the method new_record()).
  #
  # It's possible to design simple tasks where this method
  # is not necessary at all:
  #   - when there is no validation needed
  #   - the Bourreau side uses params[:interface_userfile_ids]
  #   - other options and values are stored in params by
  #     the view's input tags.
  ################################################################
  
  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def after_form #:nodoc:
    params = self.params
    #cb_error "Some error occurred."
    ""
  end
<% if options[:advanced] %>



  #***************************************************************
  #                  **** ADVANCED API ****
  #***************************************************************



  ################################################################
  # METHOD: self.properties
  ################################################################
  # This method is part of the advanced API.
  # It returns a hash table of properties that
  # describe your task; these are used by the framework to
  # override some basic assumptions about your task's behavior.
  # The default values are given here.
  ################################################################

  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def self.properties #:nodoc:
    {
       :no_submit_button                   => false, # view will not automatically have a submit button
       :i_save_my_task_in_after_form       => false, # used by validation code for detecting coding errors
       :i_save_my_tasks_in_final_task_list => false, # used by validation code for detecting coding errors
    }
  end
  


  ################################################################
  # METHOD: final_task_list
  ################################################################
  # This method is part of the advanced API. It's useful only
  # when the task object being created by the interface
  # conceptually represents a SET of task objects that need to
  # be launched. This instance method allows the programmer
  # to generate the list of task objects and return it to the
  # framework. The usual mechanism for that is to iteratively
  # invoke the clone() method on the current task object
  # and make the appropriate changes to each of the cloned
  # objects.
  #
  # The method should return an array of the cloned task
  # objects that the framework should finally save, or
  # raise an exception for any fatal errors. The
  # default behavior is tu return an array containing
  # the single element +self+, which means the current
  # task object IS the only object to save (as described
  # in the behavior of the basic API).
  #
  # You must not save the current task object, nor the
  # list of cloned task objects here.
  #
  # This method is also called when editing an existing task's
  # parameters; you can detect when this happens because the
  # task object will not be new (it will return false for
  # the method new_record()).
  ################################################################
  
  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def final_task_list #:nodoc:
    return [ self ] # default behavior
    # Example: launch ten tasks that differs in params[:cnt]
    mytasklist = []
    10.times do |cnt|
      task=self.dup # not .clone, as of Rails 3.1.10
      task.params[:cnt] = cnt
      mytasklist << task
    end
    mytasklist
  end



  ################################################################
  # METHOD: after_final_task_list_saved(tasklist)
  ################################################################
  # This method is part of the advanced API. It's a
  # callback method; the framework will call it on
  # the current task object and supply in argument
  # the task list that you've generated in final_task_list().
  # At this point, the tasks in it will have been saved
  # to the DB.
  #
  # The method should return a string to inform the user of any
  # changes or notifications, and raise an exception for any
  # fatal errors.
  ################################################################
  
  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def after_final_task_list_saved(tasklist) #:nodoc:
    ""
  end

  ################################################################
  # METHOD: untouchable_params_attributes
  ################################################################
  # This method is part of the advanced API.
  #
  # This method needs to be customized to return a hash table
  # whose keys are the attributes of params that are NOT to
  # be modified by the edit task mechanism. This is useful
  # so that attributes that encode fixed data objects that
  # are created by after_form() or final_task_list() but not
  # present in the task's form are not lost when the user edits
  # the task.
  ################################################################
  
  # RDOC comments here, if you want, although the method
  # is created with #:nodoc: in this template.
  def untouchable_params_attributes #:nodoc:
    { :interface_userfile_ids => true }
  end

<% end %>
end

