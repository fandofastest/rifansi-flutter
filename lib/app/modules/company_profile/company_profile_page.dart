import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: FigmaColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile Perusahaan',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Company Logo and Basic Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FigmaColors.primary,
                    FigmaColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Company Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'RDP',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Company Name
                  Text(
                    'PT Rifansi Dwi Putra',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Engineering, Procurement, Construction & Installation',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Company Status and Year
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(
                        icon: Icons.business,
                        label: 'Perseroan Terbatas',
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.calendar_today,
                        label: 'Since 1997',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // About Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: FigmaColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tentang Kami',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.hitam,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Since its establishment in 1997, PT Rifansi Dwi Putra (PT RDP) has already achieved an impressive track record in Indonesia in the oil and gas industries and performs design Engineering, Procurement, Construction and Installation project for PT. Chevron Pacific Indonesia among other clients.',
                    style: GoogleFonts.dmSans(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            // Offices Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: FigmaColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kantor Kami',
                          style: GoogleFonts.dmSans(
                            color: FigmaColors.hitam,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Head Office - Pekanbaru
                  _OfficeCard(
                    title: 'Head Office',
                    city: 'Pekanbaru',
                    address:
                        'Jl. Meranti 189 A, Labuh Baru Timur, Payung Sekaki, Pekanbaru, Riau',
                    phone: '62 0761 66283 ext 301',
                    email: 'mailbox@rifansi.co.id',
                    contact: 'Mr Andis Pangorian Panjaitan',
                    isHeadOffice: true,
                  ),

                  const SizedBox(height: 16),

                  // Jakarta Office
                  _OfficeCard(
                    title: 'Jakarta Office',
                    city: 'Jakarta',
                    address:
                        'Kensington Office Tower Floor 5C, Jl. Boulevard Raya No.1, RT.4/RW.17, Klp. Gading Tim., Kec. Klp. Gading, Kota Jkt Utara, Daerah Khusus Ibukota Jakarta 14240',
                    email: 'eric@rifansi.co.id',
                    contact: 'Mr. Eric Surung Silalahi',
                  ),

                  const SizedBox(height: 16),

                  // Balikpapan Office
                  _OfficeCard(
                    title: 'Balikpapan Office',
                    city: 'Balikpapan',
                    address:
                        'Perumahan Grand City, Cluster Pineville L8/18, Balikpapan 76129',
                    email: 'bintora@bpn.rifansi.co.id',
                    contact: 'Mr. Bintora',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final String title;
  final String city;
  final String address;
  final String? phone;
  final String email;
  final String contact;
  final bool isHeadOffice;

  const _OfficeCard({
    required this.title,
    required this.city,
    required this.address,
    this.phone,
    required this.email,
    required this.contact,
    this.isHeadOffice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHeadOffice
            ? Border.all(color: FigmaColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Office Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isHeadOffice
                      ? FigmaColors.primary
                      : FigmaColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isHeadOffice ? Icons.home_work : Icons.business,
                  color: isHeadOffice ? Colors.white : FigmaColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        color: FigmaColors.hitam,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      city,
                      style: GoogleFonts.dmSans(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isHeadOffice)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FigmaColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HEAD',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Address
          _ContactItem(
            icon: Icons.location_on,
            title: 'Alamat',
            content: address,
            onTap: () => _showInfo('Alamat', address),
          ),

          if (phone != null) ...[
            const SizedBox(height: 12),
            _ContactItem(
              icon: Icons.phone,
              title: 'Telepon',
              content: phone!,
              onTap: () => _showInfo('Telepon', phone!),
            ),
          ],

          const SizedBox(height: 12),
          _ContactItem(
            icon: Icons.email,
            title: 'Email',
            content: email,
            onTap: () => _showInfo('Email', email),
          ),

          const SizedBox(height: 12),
          _ContactItem(
            icon: Icons.person,
            title: 'Contact Person',
            content: contact,
          ),

          const SizedBox(height: 16),

          // Google Maps Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showInfo('Alamat Google Maps', address),
              icon: const Icon(Icons.map, size: 18),
              label: Text(
                'Lihat di Google Maps',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FigmaColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SelectableText(
          content,
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Tutup',
              style: GoogleFonts.dmSans(
                color: FigmaColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: FigmaColors.primary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: GoogleFonts.dmSans(
                      color: FigmaColors.hitam,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                color: Colors.grey[400],
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
