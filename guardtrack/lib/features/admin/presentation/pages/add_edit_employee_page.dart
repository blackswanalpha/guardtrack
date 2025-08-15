import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/models/user_model.dart';

class AddEditEmployeePage extends StatefulWidget {
  final UserModel? employee; // null for add, populated for edit

  const AddEditEmployeePage({
    super.key,
    this.employee,
  });

  @override
  State<AddEditEmployeePage> createState() => _AddEditEmployeePageState();
}

class _AddEditEmployeePageState extends State<AddEditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();

  UserRole _selectedRole = UserRole.guard;
  bool _isActive = true;
  List<String> _selectedSites = [];
  final List<String> _availableSites = [
    'Site Alpha',
    'Site Beta',
    'Site Gamma',
    'Site Delta',
    'Site Echo',
  ];

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final employee = widget.employee!;
    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
    _emailController.text = employee.email;
    _phoneController.text = employee.phone ?? '';
    _employeeIdController.text = employee.id;
    _selectedRole = employee.role;
    _isActive = employee.isActive;
    _selectedSites = employee.assignedSiteIds ?? [];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          _isEditing ? 'Edit Employee' : 'Add Employee',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.white),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfoSection(),
              const SizedBox(height: AppConstants.largePadding),
              _buildWorkInfoSection(),
              const SizedBox(height: AppConstants.largePadding),
              _buildSiteAssignmentSection(),
              const SizedBox(height: AppConstants.largePadding),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'First Name',
                  hint: 'Enter first name',
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: CustomTextField(
                  label: 'Last Name',
                  hint: 'Enter last name',
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Email',
            hint: 'Enter email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Work Information', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Employee ID',
            hint: 'Enter employee ID',
            controller: _employeeIdController,
            enabled: !_isEditing, // Don't allow editing ID
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Employee ID is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text('Role', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppConstants.smallPadding),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
            ),
            items: UserRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Checkbox(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              Text('Active Employee', style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiteAssignmentSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Site Assignments', style: AppTextStyles.heading4),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Select the sites this employee will be assigned to:',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ..._availableSites.map((site) {
            return CheckboxListTile(
              title: Text(site),
              value: _selectedSites.contains(site),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _selectedSites.add(site);
                  } else {
                    _selectedSites.remove(site);
                  }
                });
              },
              activeColor: AppColors.primaryBlue,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: _isEditing ? 'Update Employee' : 'Add Employee',
          onPressed: _saveEmployee,
          icon: _isEditing ? Icons.update : Icons.add,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        CustomButton(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
          type: ButtonType.outline,
        ),
      ],
    );
  }

  void _saveEmployee() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      final employeeData = {
        'id': _employeeIdController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'role': _selectedRole,
        'isActive': _isActive,
        'assignedSites': _selectedSites,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Employee updated successfully'
              : 'Employee added successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );

      Navigator.pop(context, employeeData);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Are you sure you want to delete ${widget.employee!.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Delete',
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, 'deleted'); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Employee deleted successfully'),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            },
            type: ButtonType.text,
            textColor: AppColors.errorRed,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
