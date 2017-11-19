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
  it 'should apply National Insurance to any amount larger than 8060' do
    employee = Employee.new
    employee.annual_salary = 9060.00

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.gross_salary).to eq(755.00)
    expect(salary_slip.national_insurance_contributions).to eq(10.00)
  end
  it 'should not apply National Insurance to any amount larger than 8060' do
    employee = Employee.new
    employee.annual_salary = 8059.99

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.national_insurance_contributions).to eq(0.00)
  end

  it 'should tax any amount of money earned above a gross annual salary of £11,000.00 is taxed at 20%' do
    employee = Employee.new
    employee.annual_salary = 12000

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.tax_free_allowance).to eq(916.67)
    expect(salary_slip.taxable_income).to eq(83.33)
    expect(salary_slip.tax_payable).to eq(16.67)
  end

  it 'should NOT tax any amount of money earned above a gross annual salary of £11,000.00' do
    employee = Employee.new
    employee.annual_salary = 11000

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)

    expect(salary_slip.tax_free_allowance).to eq(0.00)
    expect(salary_slip.taxable_income).to eq(0.00)
    expect(salary_slip.tax_payable).to eq(0.00)
  end

  it 'should apply higher contributions taxes: axable income (higher rate): Any amount of money earned above a gross annual salary of £43,000.00 is taxed' +
     'at 40% National Insurance (higher contributions): Any amount of money earned above a gross annual salary of £43,000.00 is only subject to a 2% NI contribution' do
    employee = Employee.new
    employee.annual_salary = 45000.00

    generator = SalarySlipGenerator.new
    salary_slip = generator.generate_for(employee)


    expect(salary_slip.tax_free_allowance).to eq(916.67)
    expect(salary_slip.taxable_income).to eq(2833.33)
    expect(salary_slip.tax_payable).to eq(600.00)

    expect(salary_slip.national_insurance_contributions).to eq(352.73)
  end


end