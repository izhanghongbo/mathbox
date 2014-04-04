Primitive = require '../../primitive'
Data      = require '../data/data'

class Curve extends Primitive
  @traits: ['node', 'object', 'style', 'line', 'curve', 'position', 'bind']

  constructor: (model, attributes, factory, shaders, helper) ->
    super model, attributes, factory, shaders, helper

    @line = null

  clip: () ->
    return unless @line and @bind.points

    dims = @bind.points.getActive()
    samples = dims.width
    #history = dims.height * dims.depth

    @line.geometry.clip 0, samples - 1

  make: () ->
    # Bind to attached data sources
    @_helper.bind.make
      'curve.points': Data

    # Build transform chain
    position = @_shaders.shader()
    @_helper.position.make()

    # Fetch position and transform to view
    @bind.points.shader position
    @_helper.position.shader position
    @transform position

    # Prepare bound uniforms
    styleUniforms = @_helper.style.uniforms()
    lineUniforms  = @_helper.line.uniforms()

    # Make line renderable
    dims = @bind.points.getDimensions()
    samples = dims.width
    history = dims.height * dims.depth

    @line = @_factory.make 'line',
              uniforms: @_helper.object.merge lineUniforms, styleUniforms
              samples:  samples
              ribbons:  history
              position: position

    @clip()

    @_helper.object.make [@line]

  unmake: () ->
    @_helper.bind.unmake()
    @_helper.object.unmake()
    @_helper.position.unmake()

  change: (changed, touched, init) ->
    @rebuild() if changed['curve.points']?

module.exports = Curve