Then("the {string} should have a {int} hour alert set against it") do |item_type, h|
  time = h.hours.from_now
  @alert = @item.alerts.active.due_at(time).first
  expect(@alert).to_not be_nil
end

When("the {int} hour alert has passed") do |int|
  Timecop.travel @alert.due_at do
    @alert.trigger
  end
end

Then("the {string} should have a status of {string}") do |item_type, status|
  expect(@item.status.reference).to eq status
end

Then("the previous alert should be inactive") do
  @alert.reload
  expect(@alert).to be_inactive
end

Then("the {string} should be completed") do |item_type|
  expect(@item).to be_completed
end
