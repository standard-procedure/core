Then("the {string} should have a {int} hour alert set against it") do |item_type, h|
  time = h.hours.from_now
  @alert = @item.alerts.waiting.due_at(time).first
  expect(@alert).to_not be_nil
end

When("the {int} hour delivery alert has passed") do |int|
  # do nothing
end

Then("the {string} should have a status of {string}") do |item_type, status|
  expect(@item.status.reference).to eq status
end

Then("the previous alert should be inactive") do
  @alert.reload
  expect(@alert).to be_inactive
end
