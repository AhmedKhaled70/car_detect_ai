import 'package:flutter/material.dart';

class History_Tab extends StatelessWidget {
  const History_Tab({super.key});

  @override
  Widget inspectionCard({
    required String status,
    required Color statusColor,
    required String carName,
    required String date,
    required String number,
    required String image,
    required bool mainButton,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      carName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        Text(date),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '# رقم الفحص $number',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),

              /// Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(mainButton ? Icons.description : Icons.arrow_forward),
              label: Text(mainButton ? 'عرض التقرير الكامل' : 'متابعة الفحص'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainButton
                    ? Colors.blue
                    : Colors.blue.withOpacity(.1),
                foregroundColor: mainButton ? Colors.white : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      /// Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ابحث عن فحص معين...',
                  icon: Icon(Icons.search),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Cards
            inspectionCard(
              status: 'مكتمل',
              statusColor: Colors.green,
              carName: 'تويوتا كامري 2023',
              date: '12 أكتوبر 2023',
              number: 'IN-8821#',
              image: 'assets/images/toyota.jpg',
              mainButton: true,
            ),

            inspectionCard(
              status: 'مكتمل',
              statusColor: Colors.green,
              carName: 'مرسيدس C300 2021',
              date: '05 أكتوبر 2023',
              number: 'IN-8610#',
              image: 'assets/images/c300.jpg',
              mainButton: true,
            ),

            inspectionCard(
              status: 'مكتمل',
              statusColor: Colors.green,
              carName: 'بورش كايين 2023',
              date: '01 أكتوبر 2023',
              number: 'IN-8592#',
              image: 'assets/images/porch.jpg',
              mainButton: true,
            ),
          ],
        ),
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// small circle icon
  Widget _circleIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xffF1F3F6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.blue),
      ),
    );
  }
}
