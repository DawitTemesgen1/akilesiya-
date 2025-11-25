import 'package:amde_haymanot_abalat_guday/users%20screen/social_media_url.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Responsive(
      mobile: _AboutUsMobile(),
      tablet: _AboutUsTablet(),
    );
  }
}

class _AboutUsMobile extends StatelessWidget {
  const _AboutUsMobile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, 300),
          _buildSliverBody(context, 2),
        ],
      ),
    );
  }
}

class _AboutUsTablet extends StatelessWidget {
  const _AboutUsTablet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, 400),
          _buildSliverBody(context, 4),
        ],
      ),
    );
  }
}

class _Responsive extends StatelessWidget {
  const _Responsive({
    required this.mobile,
    required this.tablet,
  });

  final Widget mobile;
  final Widget tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else {
          return tablet;
        }
      },
    );
  }
}

TextStyle _amharicTextStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.white70,
  double height = 1.8,
  double? letterSpacing,
  FontStyle? fontStyle,
}) {
  return GoogleFonts.notoSansEthiopic(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
  );
}

SliverAppBar _buildSliverAppBar(BuildContext context, double expandedHeight) {
  return SliverAppBar(
    expandedHeight: expandedHeight,
    pinned: true,
    backgroundColor: const Color(0xFF7C3AED),
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Iconsax.home,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ዓምደ ሃይማኖት',
                    style: _amharicTextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'የሰንበት ትምህርት ቤት',
                    style: _amharicTextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

SliverToBoxAdapter _buildSliverBody(
  BuildContext context,
  int crossAxisCount,
) {
  return SliverToBoxAdapter(
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0F2D), Color(0xFF1A1F3D)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildVisionSection(),
          const SizedBox(height: 60),
          _buildStorySection(),
          const SizedBox(height: 60),
          _buildValuesSection(crossAxisCount),
          const SizedBox(height: 60),
          _buildDeveloperSection(),
          const SizedBox(height: 60),
          _buildConnectSection(),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

Widget _buildVisionSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'ራዕያችን',
            style: _amharicTextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'በሃይማኖትና በምግባር የታነጸ ጥበበኛ ትውልድን መፍጠር',
          textAlign: TextAlign.center,
          style: _amharicTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ቅዱሳን አባቶች ያስረከቡንን የቤተ ክርስቲያን ዶግማ፣ ቀኖናና ትውፊት በማክበርና በማስከበር፣ ለመንግስተ ሰማያት የሚያበቃ የጸና ሃይማኖትና ምግባር ያለው ትውልድ ተፈጥሮ ማየት።',
          textAlign: TextAlign.center,
          style: _amharicTextStyle(
            fontSize: 16,
            height: 1.7,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStorySection() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF334155)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.book, color: Color(0xFFF59E0B), size: 24),
            const SizedBox(width: 12),
            Text(
              'ታሪካችን',
              style: _amharicTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'የጅማ ደብረ ኤፍራታ ቅድስት ድንግል ማርያም ቤተ ክርስቲያን ዓምደ ሃይማኖት ሰንበት ትምህርት ቤት በ፲፱፻፷፬ ዓ.ም ተመሠረተ። ላለፉት በርካታ ዓመታትም ጥቂት የማይባሉ የቤተ ክርስቲያን ልጆችን በመንፈሳዊ አገልግሎት እያፈራ ይገኛል።',
          textAlign: TextAlign.justify,
          style: _amharicTextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          'ይህ ዲጂታል መድረክ ጥንታዊውን የቤተክርስቲያናችንን ትውፊት ከዘመናዊ ቴክኖሎጂ ጋር በማጣመር፣ በመንፈሳዊ ጉዟቸው ላይ ያሉትን የማኅበረሰባችን አባላት ለመደገፍና ተደራሽ የሆኑ መንፈሳዊ ሀብቶችን ለማቅረብ የተዘጋጀ ነው።',
          textAlign: TextAlign.justify,
          style: _amharicTextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}

Widget _buildValuesSection(int crossAxisCount) {
  final values = [
    {
      'icon': Iconsax.heart,
      'title': 'ሃይማኖት',
      'description': 'በምግባር የተገለጠ የጸና እምነት',
      'color': const Color(0xFFEF4444),
    },
    {
      'icon': Iconsax.people,
      'title': 'ፍቅር',
      'description': 'በፍቅረ እግዚአብሔርና ፍቅረ ቢጽ የተሳሰረ',
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Iconsax.book_1,
      'title': 'ትምህርት',
      'description': 'ተከታታይ መንፈሳዊና ሰብአዊ ዕድገት',
      'color': const Color(0xFFF59E0B),
    },
    {
      'icon': Iconsax.gift,
      'title': 'አገልግሎት',
      'description': 'እግዚአብሔርንና ማኅበረሰቡን በትጋት ማገልገል',
      'color': const Color(0xFF8B5CF6),
    },
  ];

  return Column(
    children: [
      Text(
        'መሠረታዊ እሴቶቻችን',
        style: _amharicTextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'ተልዕኳችንን የሚመሩ ምሰሶዎች',
        style: _amharicTextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 40),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemCount: values.length,
          itemBuilder: (context, index) {
            final value = values[index];
            return Hero(
              tag: 'value-$index', // Unique tag for each item
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: value['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          value['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        value['title'] as String,
                        style: _amharicTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value['description'] as String,
                        textAlign: TextAlign.center,
                        style: _amharicTextStyle(
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildDeveloperSection() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        const Icon(Iconsax.code, size: 50, color: Colors.white),
        const SizedBox(height: 20),
        Text(
          'በእምነት እና በቴክኖሎጂ የተገነባ',
          style: _amharicTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ይህ ዲጂታል መድረክ የተዘጋጀው በዓምደ ሃይማኖት ሰንበት ትምህርት ቤት መሪነት ሲሆን፣ መንፈሳዊ ጥበብን ከቴክኒካዊ ብቃት ጋር አጣምሮ ይዟል።',
          textAlign: TextAlign.center,
          style: _amharicTextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.programming_arrow,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ዓምደ ሃይማኖት ሰንበት ትምህር ቤት',
                      style: _amharicTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildConnectSection() {
  return Column(
    children: [
      Text(
        'የዲጂታል ማኅበረሰባችንን ይቀላቀሉ',
        style: _amharicTextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'ከእያደገ ካለው ቤተሰባችን ጋር እንደተገናኙ ይቆዩ',
        style: _amharicTextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 40),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              'ዕለታዊ መንፈሳዊ መልዕክቶችን፣ የክስተት ማስታወቂያዎችን እና መንፈሳዊ መመሪያዎችን ለማግኘት በማኅበራዊ ትስስር ገጾቻችን ይከታተሉን። በጋራ፣ ለዘመናዊው ትውልድ የሚሆን የእምነት ማኅበረሰብ እየገነባን ነው።',
              textAlign: TextAlign.center,
              style: _amharicTextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const SocialMediaUrl(),
            const SizedBox(height: 20),
            Text(
              'ዓምደ ሃይማኖት ሰንበት ትምህርት ቤት፣ ጅማ ኢትዮጵያ',
              textAlign: TextAlign.center,
              style: _amharicTextStyle(
                fontSize: 14,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
