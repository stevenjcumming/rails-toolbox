class Api::V1::ExamplesController < Api::V1::ApplicationController

  before_action :set_example, only: %i[show update destroy]

  def index
    @examples = current_user.examples
    # or for policies
    # @examples = policy_scope(Example)
  end

  def show; end

  def create
    example_form = ExampleForm.new(example_params, current_user)
    if example_form.save
      @example = example_form.example
    else
      errors = example_form.errors
      render json: { errors: errors }, status: :bad_request
    end
  end

  def update
    example_form = ExampleForm.new(example_params.merge(example: @example), current_user)
    if example_form.save
      @example = example_form.example
    else
      errors = example_form.errors
      render json: { errors: errors }, status: :bad_request
    end
  end

  def destroy
    if @example.desetroy
      head :ok
    else
      errors = @example.errors
      render json: { errors: errors }, status: :bad_request
    end
  end

  private

    def set_example
      @example = current_user.examples.find_by_id(params[:id].to_i)
      # or for policies
      # @example = policy_scope(Example).find_by_id(params[:id].to_i)
      # if you use reference_id use .find_by_reference_id
      unless @example
        # For security reasons even if record is not found return unauthorized
        render json: { errors: [UnauthorizedError.new] }, status: :unauthorized
      end
    end

    def example_params
      params.permit(:param_1, :param_2, :param_3)
    end

end
