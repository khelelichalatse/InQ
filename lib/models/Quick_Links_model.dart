// Model class representing Quick access links for the application

class Link {
  final String title;    
  final String url;      
  final String image;   

  Link({required this.title, required this.url, required this.image});
}

// Predefined list of quick access links for the application
List<Link> links = [
  Link(
      title: 'Cental University of Technology',
      url: 'https://www.cut.ac.za/',
      image: 'assets/CUT-Logo.png'),
  Link(
      title: 'NSFAS',
      url: 'https://www.nsfas.org.za/content/',
      image: 'assets/NSFAS-logo.jpg'),
  Link(
      title: 'Self Help iEnabler',
      url: 'https://enroll.cut.ac.za/pls/prodi41/w99pkg.mi_login',
      image: 'assets/CUT-Logo.png'),
  // Add more links here
];