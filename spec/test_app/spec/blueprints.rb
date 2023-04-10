# Test builders
when_creating_a User, auto_generate: [:reference]
when_creating_a Category, auto_generate: [:name]
when_creating_a Thing, auto_generate: [:name], generate: {category: -> { a_saved Category }, user: -> { a_saved User }}

# StandardProcedure builders
when_creating_a StandardProcedure::Workflow, auto_generate: [:name]
when_creating_a StandardProcedure::WorkflowStatus, auto_generate: [:name], generate: {workflow: -> { a_saved StandardProcedure::Workflow }}
