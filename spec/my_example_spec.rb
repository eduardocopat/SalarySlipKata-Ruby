require 'rspec'
require 'require_all'
require_all 'src'

describe 'Salary Slip Generator' do
  it 'should generate for annual salary with employee data' do
    employee = Employee.new
    employee.id = 12345
    employee.name = 'John J Doe'
    employee.annual_salary = 5000.00

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.employee_id).to eq(12345)
    expect(salary_slip.employee_name).to eq('John J Doe')
    expect(salary_slip.gross_salary).to eq(416.67)
  end
  it 'should contribute to National Insurance if annual is larger than 8060' do
    employee = Employee.new
    employee.annual_salary = 9060.00

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.gross_salary).to eq(755.00)
    expect(salary_slip.national_insurance_contributions).to eq(90.60)
  end
  it 'should not contribute to National Insurance if annual is lower than 8060' do
    employee = Employee.new
    employee.annual_salary = 8059.99

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.national_insurance_contributions).to eq(0.00)
  end


end