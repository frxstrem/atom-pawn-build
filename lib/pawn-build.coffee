{CompositeDisposable} = require 'atom'
path = require 'path'
child_process = require 'child_process'

module.exports = PawnBuild =
  modalPanel: null
  subscriptions: null

  config:
    pawnExecutablePath:
      title: 'Path to pawncc executable'
      type: 'string'
      default: 'C:\\pawn\\pawncc.exe'
    pawnOptions:
      title: 'Pawn options'
      type: 'array'
      default: ['-d1', '-(', '-;']
      items:
        type: 'string'

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'pawn-build:build': => @build()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @pawnBuildView.destroy()

  serialize: -> undefined

  build: ->
    filepath = atom.workspace.getActiveTextEditor()?.getPath()

    # ignore command if current file is not saved, or is not a .pwn file
    return unless filepath? and path.extname(filepath) == '.pwn'

    # prepare command
    cmd = atom.config.get('pawn-build.pawnExecutablePath')

    # prepare arguments
    args = atom.config.get('pawn-build.pawnOptions')
    args.push path.basename filepath

    console.debug filepath, cmd, args

    # run pawn
    child_process.execFile cmd, args,
      cwd: path.dirname filepath
    , (error, stdout, stderr) ->
      console.error error if error?
      console.error stderr if stderr
