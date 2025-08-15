import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/whatsapp_contact.dart';

class ContactPicker extends StatefulWidget {
  final List<WhatsAppContact> contacts;
  final List<WhatsAppContact> selectedContacts;
  final Function(List<WhatsAppContact>) onContactsChanged;
  final VoidCallback? onAddContact;
  final bool allowMultipleSelection;

  const ContactPicker({
    super.key,
    required this.contacts,
    required this.selectedContacts,
    required this.onContactsChanged,
    this.onAddContact,
    this.allowMultipleSelection = true,
  });

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<WhatsAppContact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = widget.contacts.where((contact) {
        return contact.name.toLowerCase().contains(query) ||
            contact.phoneNumber.contains(query) ||
            (contact.company?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSearchField(),
          const SizedBox(height: AppConstants.defaultPadding),
          if (widget.selectedContacts.isNotEmpty) _buildSelectedContacts(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildContactList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.contacts,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Select Contacts',
              style: AppTextStyles.heading4,
            ),
          ],
        ),
        if (widget.onAddContact != null)
          IconButton(
            onPressed: widget.onAddContact,
            icon: Icon(
              Icons.person_add,
              color: AppColors.primaryBlue,
            ),
            tooltip: 'Add Contact',
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search contacts...',
        prefixIcon: Icon(Icons.search, color: AppColors.gray500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
    );
  }

  Widget _buildSelectedContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected (${widget.selectedContacts.length})',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          spacing: AppConstants.smallPadding,
          runSpacing: AppConstants.smallPadding,
          children: widget.selectedContacts.map((contact) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contact.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeContact(contact),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactList() {
    if (_filteredContacts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = _filteredContacts[index];
          final isSelected = widget.selectedContacts.any((c) => c.id == contact.id);
          
          return _buildContactItem(contact, isSelected);
        },
      ),
    );
  }

  Widget _buildContactItem(WhatsAppContact contact, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Material(
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.gray50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: InkWell(
          onTap: () => _toggleContact(contact),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primaryBlue : AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.formattedPhoneNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      if (contact.groups.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: contact.groups.take(2).map((group) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                group,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.allowMultipleSelection)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleContact(contact),
                    activeColor: AppColors.primaryBlue,
                  )
                else if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            _searchController.text.isNotEmpty ? 'No contacts found' : 'No contacts available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            _searchController.text.isNotEmpty 
                ? 'Try adjusting your search terms'
                : 'Add your first contact to get started',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleContact(WhatsAppContact contact) {
    final selectedContacts = List<WhatsAppContact>.from(widget.selectedContacts);
    final isSelected = selectedContacts.any((c) => c.id == contact.id);

    if (isSelected) {
      selectedContacts.removeWhere((c) => c.id == contact.id);
    } else {
      if (widget.allowMultipleSelection) {
        selectedContacts.add(contact);
      } else {
        selectedContacts.clear();
        selectedContacts.add(contact);
      }
    }

    widget.onContactsChanged(selectedContacts);
  }

  void _removeContact(WhatsAppContact contact) {
    final selectedContacts = List<WhatsAppContact>.from(widget.selectedContacts);
    selectedContacts.removeWhere((c) => c.id == contact.id);
    widget.onContactsChanged(selectedContacts);
  }
}
