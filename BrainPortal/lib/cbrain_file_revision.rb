
# This class encapsulates an information record about
# the revision control history of a file. It was created
# as a transition mechanism between SVN and GIT. In SVN
# all classes used to define a constant called Revision_info
# whose value would be initialized by the programmer to the
# string'$Id$' but would be substituted, by SVN, for a
# longer description of the file's name, commit ID,
# commit author and date. As a replacement, we now
# require programmers to add this at the beginning of
# their classes:
#
#   Revision_info=CbrainFileRevision[__FILE__]
#
# This initalize the constant to a handler object of
# class CbrainFileRevision which records the file path
# in one of its internal attribute. Later one, if
# a piece of code wants to extract from it its revision
# ID (or author name etc) then a 'git' command will be
# issued to extract the info, and it will be cached in
# the object. The process is 'lazy' in that the git
# command is only executed the first time a to_s() is
# invoked.
#
# Objects of this class, otherwise, belong much like
# strings, but sometimes you might want to call to_s()
# or self_update() explicitely.
#
# Examples:
#
#   # At the top of a class:
#   class Abcd
#     Revision_info=CbrainFileRevision[__FILE__]
#   end
#
#   # Then later on, all these calls are similar:
#   puts Abcd::Revision_info.to_s # in SVN-like format
#   puts Abcd::Revision_info.svn_id_rev # using CBRAIN's svn_id_rev parser
#   puts Abcd.revision_info.svn_id_rev  # using CBRAIN's revision_info method
#   x = Abcd.new
#   puts x.revision_info.svn_id_rev
#   puts x.revision_info.short_commit # using attributes
#
#   # If at least once to_s() or self_update() has been called,
#   # the the attributes can also be accessed directly:
#   Abcd::Revision_info.self_update
#   puts Abcd::Revision_info.author  # faster than svn_id_author()
#
class CbrainFileRevision

  # Attributes for linking the object to the disk file
  attr_accessor :fullpath
  attr_accessor :basename

  # Official attributes
  attr_accessor :author, :commit, :short_commit, :date, :time

  # Fake SVN ID
  attr_accessor :fake_svn_id_string

  # GIT info cache
  attr_accessor :git_last_commit_info

  def initialize(fullpath) #:nodoc:
    self.fullpath = fullpath
  end

  # Same as new() method. This allows you to
  # initialize an object in a prettier way:
  #
  #   # Standard:
  #   Revision_info = CbrainRevisionInfo.new(__FILE__)
  #
  #   # Prettier:
  #   Revision_info = CbrainRevisionInfo[__FILE__]
  def self.[](fullpath)
    self.new(fullpath)
  end

  # Returns the revision info in a fake 'svn' format:
  #   "$Id: en_cbrain_local_data_provider.rb 12ab34 2010-03-25 17:26:05Z prioux $"
  # Note that this triggers a self_update() call, if necessary, the first time.
  def to_s
    return @fake_svn_id_string if ! @fake_svn_id_string.nil? # Cached; no need to fetch git info every time.
    self_update()
    @fake_svn_id_string = "$Id: #{@basename} #{@short_commit} #{@date} #{@time} #{@author} $"
    @fake_svn_id_string
  end

  # Inspect the revision object but will not trigger a self_update(),
  # so the returned string might contain all blank fields.
  def inspect
    "<#{self.class.to_s}##{self.object_id} @basename=#{@basename.inspect} @short_commit=#{@short_commit.inspect} @date=#{@date.inspect} @time=#{@time.inspect} @author=#{@author.inspect}>"
  end

  # Make the object act as a string
  def method_missing(name,*args) #:nodoc:
    # 'name' will be provided by Ruby as :myattr or :myattr=
    self.to_s.send(name,*args)
  end

  def =~(*args) #:nodoc:
    self.to_s.=~(*args)
  end

  # Makes the class access the GIT repository and
  # updates its attributes to represent the current
  # file's GIT state.
  def self_update(force=nil)
    @git_last_commit_info=nil if force
    self.get_git_rev_info()
    self
  end

  # Class method. Slurps a static file of revision info.
  def self.load_static_revision_file(path=nil) #:nodoc:
    return unless @_static_revision_hash.blank?
    cbrain_root   = Pathname.new(Rails.root).parent
    path        ||= cbrain_root + "cbrain_file_revisions.csv"
    @_static_revision_hash = {}
    File.open(path.to_s,"r") do |fh|
      fh.readlines.each do |line|
        line.chomp!
        # 7f6bb2f24f6afb3d3b355d6c0ad630cdf353e1fe -#- 2011-07-18 17:16:57 -0400 -#- Pierre Rioux -#- Bourreau/README
        fields   = line.split(" -#- ")
        commit   = fields[0]
        datetime = fields[1]
        author   = fields[2]
        relpath  = fields[3]
        @_static_revision_hash[relpath] = [ commit, datetime, author ] unless relpath.blank?
        #puts_blue "-> #{@_static_revision_hash[relpath].inspect}"
      end
    end
    true
  end

  def self.static_revision_for_relpath(relpath) #:nodoc:
    @_static_revision_hash[relpath]
  end

  def self.git_available? #:nodoc:
    return @_git_available == :yes unless @_git_available.blank?
    test = `bash -c "which git 2>/dev/null"`
    @_git_available = (test.blank? ? :no : :yes)
    if @_git_available == :yes
      test2 = `git log -n 1 -- #{Rails.root} 2>/dev/null`
      @_git_available = :no if test2.blank?
    end
    @_git_available == :yes
  end

  protected

  def get_git_rev_info #:nodoc:
    return @commit unless @git_last_commit_info.nil?

    # 9f4c0900fa3e6c87131d830194d0276acb1ce595 2011-06-28 17:50:26 -0400 Pierre Rioux
    @git_last_commit_info = "" # now that it's no longer nil, will not try to fetch again

    @basename = File.basename(@fullpath)
    @commit   = "UnknownId" ; @short_commit = @commit
    @date     = "0000-00-00"
    @time     = "00:00"
    @author   = "UnknownAuthor"

    if self.class.git_available?
      self.get_git_rev_info_from_git
    else
      self.get_git_rev_info_from_static_file
    end
  end

  def get_git_rev_info_from_static_file #:nodoc:
    self.class.load_static_revision_file
    cbrain_root = Pathname.new(Rails.root).parent
    relpath     = @fullpath ; relpath["#{cbrain_root}/"] = ""  # transforms /path/to/root/a/b/c -> /a/b/c"
    revinfo     = self.class.static_revision_for_relpath(relpath)
    if !revinfo # if the root of the app has been renamed... try BrainPortal
      relpath.sub!(/^[^\/]+\//,"BrainPortal/")
      revinfo  = self.class.static_revision_for_relpath(relpath)
    end
    if !revinfo # if the root of the app has been renamed... try Bourreau
      relpath.sub!(/^[^\/]+\//,"Bourreau/")
      revinfo  = self.class.static_revision_for_relpath(relpath)
    end
    return false unless revinfo
   
    @commit   = revinfo[0] ; @short_commit = @commit[0..5]
    datetime  = revinfo[1]
    if datetime =~ /(\d\d\d\d-\d\d-\d\dT?)\s*(\d\d:\d\d:\d\dZ?)(\s*[+-][\d:]+)?/
      @date   = Regexp.last_match[1]
      @time   = Regexp.last_match[2] + (Regexp.last_match[3] || "")
    end
    @author   = revinfo[2]

    @commit
  end

  def get_git_rev_info_from_git #:nodoc:

    dirname   = File.dirname(@fullpath)

    Dir.chdir(dirname) do
      # If symlink, try to deref
      target = File.symlink?(@basename) ? File.readlink(@basename) : @basename
      File.popen("git rev-list --max-count=1 --date=iso --pretty=format:'%H %ad %an' HEAD -- ./'#{target}' 2>/dev/null","r") do |fh|
        line = fh.readline.strip rescue ""
        if line =~ /\d\d\d\d-\d\d-\d\d/
          @git_last_commit_info = line
        else
          line = fh.readline.strip rescue ""
          @git_last_commit_info = line if line =~ /\d\d\d\d-\d\d-\d\d/
        end
      end
    end

    if @git_last_commit_info =~ /^(\S+) (\d\d\d\d-\d\d-\d\dT?)\s*(\d\d:\d\d:\d\dZ?)(\s*[+-][\d:]+)? (\S.*\S)\s*$/
      @commit = Regexp.last_match[1] ; @short_commit = @commit[0..5]
      @date   = Regexp.last_match[2]
      @time   = Regexp.last_match[3] + (Regexp.last_match[4] || "")
      @author = Regexp.last_match[5]
    end

    @commit
  end

end
