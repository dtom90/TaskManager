require 'rails_helper'

task1 = {
  name: 'My test task',
  description: 'This is the description of my task 1',
  due_date: Date.parse('2019-01-01')
}

task2 = {
  name: 'My test task 2',
  description: 'This is the description of my task 2',
  due_date: Date.parse('2019-01-02')
}

task_today = {
  name: 'My today task',
  description: 'This is the description of my task today',
  due_date: Date.today()
}

task_tomorrow = {
  name: 'My tomorrow task',
  description: 'This is the description of my task tomorrow',
  due_date: Date.today()+1
}

task_yesterday = {
  name: 'My yesterday task',
  description: 'This is the description of my task yesterday',
  due_date: Date.today()-1
}

RSpec.feature "Manage Tasks", type: :feature, js: true do
  
  scenario "Create, View All" do
    
    visit '/'
    
    ###
    puts '1. As a user, I need to be able to create a task for myself providing a task name, description, and due date.'
    ###

    expect(page).to have_text 'Tasks'
    create_task(task1)
    create_task(task2)
    create_task(task_yesterday)
    create_task(task_today)
    create_task(task_tomorrow)
    
    ###
    puts '2. As a user, I need to be able to see a list of existing tasks.'
    ###
    
    expect_task_in_list(task1)
    expect_task_in_list(task2)
    expect_task_in_list(task_yesterday)
    expect_task_in_list(task_today)
    expect_task_in_list(task_tomorrow)
    
    ###
    puts '3. As a user, I need to be able to view the details of a specific task.'
    ###

    within '#task_1' do
      click_link 'Details'
    end
    expect_task_details(task1)
    
    ###
    puts '4. As a user, I need to be able to mark a task as completed.'
    ###

    click_link '<- All Tasks'
    page.check('task_1_completed')
    expect(page.find('input#task_1_completed')).to be_checked
    
    ###
    puts '5. As a user, I need to be able to remove a task.'
    ### 

    within '#task_2' do
      click_link 'Destroy'
    end
    expect_task_in_list(task1)
    expect_task_in_list(task2, absent=true)
    expect_task_in_list(task_yesterday)
    expect_task_in_list(task_today)
    expect_task_in_list(task_tomorrow)
    
    ###
    puts '6. As a user, I need to be able to filter my list of tasks to just those tasks due tomorrow and / or today.'
    ###

    # Filter today
    page.check('Due Today')

    # Expect only task_today to be visible
    expect_task_in_list(task1, absent=true)
    expect_task_in_list(task_yesterday, absent=true)
    expect_task_in_list(task_today)
    expect_task_in_list(task_tomorrow, absent=true)

    # Filter tomorrow as well
    page.check('Due Tomorrow')

    # Expect task_today and task_tomorrow to be visible
    expect_task_in_list(task1, absent=true)
    expect_task_in_list(task_yesterday, absent=true)
    expect_task_in_list(task_today)
    expect_task_in_list(task_tomorrow)

    # Filter only tomorrow
    page.uncheck('Due Today')

    # Expect only task_tomorrow to be visible
    expect_task_in_list(task1, absent=true)
    expect_task_in_list(task_yesterday, absent=true)
    expect_task_in_list(task_today, absent=true)
    expect_task_in_list(task_tomorrow)

    ###
    puts '7. As a user, I need to be able to filter my list of tasks to just those tasks which are overdue.'
    ###
    
    # Uncheck filters & Filter overdue
    page.uncheck('Due Tomorrow')
    page.check('Overdue')
    
    # Expect only task_yesterday to be visible
    expect_task_in_list(task1, absent=true)
    expect_task_in_list(task_yesterday)
    expect_task_in_list(task_today, absent=true)
    expect_task_in_list(task_tomorrow, absent=true)
    
    ###
    puts '8. As a user, I need to be able to filter my list of tasks to just those tacks which have been marked as completed.'
    ###

    page.check('Completed')
    expect_task_in_list(task1)
    expect_task_in_list(task_yesterday, absent=true)
    expect_task_in_list(task_today, absent=true)
    expect_task_in_list(task_tomorrow, absent=true)
    
    ###
    # 9. As a user, I need a visual indication of which tasks are due tomorrow and / or today as well as
    # those tasks which are past due (2 different indications).
    ###
    
  end

end

def create_task(task)
  
  click_link 'New Task'

  expect(page).to have_text 'New Task'
  expect(page).to have_button 'Create Task'

  fill_in 'Name', with: task[:name]
  fill_in 'Description', with: task[:description]

  expect(page).to have_text 'Due date'
  select task[:due_date].year, from: 'task_due_date_1i'
  select task[:due_date].strftime('%B'), from: 'task_due_date_2i'
  select task[:due_date].mday, from: 'task_due_date_3i'

  expect(page).to_not have_text 'Completed'
  
  click_button 'Create Task'
  
end

def expect_task_in_list(task, absent=false)
  expect(page).to have_text "Completed Name Description Due date"
  if absent
    expect(page).to_not have_text "#{task[:name]} #{task[:description]} #{task[:due_date]} Details Edit Destroy"
  else
    expect(page).to have_text "#{task[:name]} #{task[:description]} #{task[:due_date]} Details Edit Destroy"
  end
end

def expect_task_details(task)

  expect(page).to have_link '<- All Tasks'
  expect(page).to have_text "Name: #{task[:name]}"
  expect(page).to have_text "Description: #{task[:description]}"
  expect(page).to have_text "Due date: #{task[:due_date]}"
  expect(page).to have_link 'Edit'
  
end
