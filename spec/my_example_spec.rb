require 'rspec'
require 'require_all'
require_all 'src'

describe 'Salary Slip Generator' do
  it 'should generate for annual salary' do
    employee = Employee.new
    employee.id = 12345
    employee.name = 'John J Doe'
    employee.annual_salary = 5000

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.employee_id).to eq(12345)
    expect(salary_slip.employee_name).to eq('John J Doe')
    expect(salary_slip.gross_salary).to eq(416.67)
  end
end