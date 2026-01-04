import 'dart:math';

/// Question model
class Question {
  final int id;
  final String type;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? imageUrl;
  final String? imageSemanticLabel;
  final int points;

  const Question({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.imageUrl,
    this.imageSemanticLabel,
    this.points = 10,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'imageUrl': imageUrl,
    'imageSemanticLabel': imageSemanticLabel,
    'points': points,
  };
}

/// QuestionService - Provides program-specific questions
class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  final Random _random = Random();

  /// Get 10 randomized questions for a specific program and level
  List<Map<String, dynamic>> getQuestionsForLevel(String programId, int levelId) {
    final allQuestions = _getQuestionBank(programId);
    final zoneIndex = ((levelId - 1) ~/ 6);
    final levelInZone = ((levelId - 1) % 6);
    
    // Get questions for this zone
    final zoneQuestions = _getZoneQuestions(allQuestions, zoneIndex);
    
    // Select 10 questions based on level difficulty
    final selectedQuestions = _selectQuestions(zoneQuestions, levelInZone, 10);
    
    // Randomize order
    selectedQuestions.shuffle(_random);
    
    return selectedQuestions.map((q) => q.toMap()).toList();
  }

  List<Question> _getZoneQuestions(List<Question> allQuestions, int zoneIndex) {
    final startIdx = zoneIndex * 60;
    final endIdx = (startIdx + 60).clamp(0, allQuestions.length);
    if (startIdx >= allQuestions.length) return allQuestions;
    return allQuestions.sublist(startIdx, endIdx);
  }

  List<Question> _selectQuestions(List<Question> questions, int levelInZone, int count) {
    if (questions.length <= count) return List.from(questions);
    
    final startIdx = (levelInZone * 10) % questions.length;
    final selected = <Question>[];
    
    for (int i = 0; i < count && i < questions.length; i++) {
      selected.add(questions[(startIdx + i) % questions.length]);
    }
    
    return selected;
  }

  List<Question> _getQuestionBank(String programId) {
    switch (programId.toLowerCase()) {
      case 'bsit': return _bsitQuestions;
      case 'bsba': return _bsbaQuestions;
      case 'bsed': return _bsedQuestions;
      case 'beed': return _beedQuestions;
      case 'bsa': return _bsaQuestions;
      case 'bshm': return _bshmQuestions;
      case 'bscs': return _bscsQuestions;
      case 'bscpe': return _bscpeQuestions;
      case 'ahm': return _ahmQuestions;
      default: return _bsitQuestions;
    }
  }

  // BSIT - Information Technology Questions
  static final List<Question> _bsitQuestions = [
    // Zone 1: Programming Fundamentals (Questions 1-60)
    Question(id: 1, type: 'multiple_choice', question: 'What does HTML stand for?', options: ['Hyper Text Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language', 'Hyperlink Text Management Language'], correctIndex: 0, explanation: 'HTML stands for Hyper Text Markup Language, the standard markup language for web pages.'),
    Question(id: 2, type: 'multiple_choice', question: 'Which programming language is known as the backbone of web development?', options: ['Python', 'JavaScript', 'C++', 'Ruby'], correctIndex: 1, explanation: 'JavaScript is essential for web development, enabling interactive web pages.'),
    Question(id: 3, type: 'true_false', question: 'CSS is used for styling web pages.', options: ['True', 'False'], correctIndex: 0, explanation: 'CSS (Cascading Style Sheets) is used to style and layout web pages.'),
    Question(id: 4, type: 'multiple_choice', question: 'What is the purpose of a variable in programming?', options: ['To store data', 'To create loops', 'To define functions', 'To connect databases'], correctIndex: 0, explanation: 'Variables are used to store data values in programming.'),
    Question(id: 5, type: 'multiple_choice', question: 'Which data type stores whole numbers?', options: ['String', 'Boolean', 'Integer', 'Float'], correctIndex: 2, explanation: 'Integer data type stores whole numbers without decimal points.'),
    Question(id: 6, type: 'multiple_choice', question: 'What is a loop in programming?', options: ['A bug in code', 'A repeated sequence of instructions', 'A type of variable', 'A database query'], correctIndex: 1, explanation: 'A loop executes a sequence of instructions repeatedly until a condition is met.'),
    Question(id: 7, type: 'true_false', question: 'Python uses indentation to define code blocks.', options: ['True', 'False'], correctIndex: 0, explanation: 'Python uses indentation instead of braces to define code blocks.'),
    Question(id: 8, type: 'multiple_choice', question: 'What does IDE stand for?', options: ['Internet Development Environment', 'Integrated Development Environment', 'Internal Data Exchange', 'Interactive Design Editor'], correctIndex: 1, explanation: 'IDE stands for Integrated Development Environment, a software for writing code.'),
    Question(id: 9, type: 'multiple_choice', question: 'Which symbol is used for comments in Python?', options: ['//', '/*', '#', '--'], correctIndex: 2, explanation: 'Python uses the hash symbol (#) for single-line comments.'),
    Question(id: 10, type: 'multiple_choice', question: 'What is an array?', options: ['A single value', 'A collection of values', 'A function', 'A loop type'], correctIndex: 1, explanation: 'An array is a data structure that stores a collection of elements.'),
    Question(id: 11, type: 'multiple_choice', question: 'What does SQL stand for?', options: ['Structured Query Language', 'Simple Question Language', 'Standard Quality Language', 'System Query Logic'], correctIndex: 0, explanation: 'SQL stands for Structured Query Language, used for database management.'),
    Question(id: 12, type: 'true_false', question: 'Java and JavaScript are the same programming language.', options: ['True', 'False'], correctIndex: 1, explanation: 'Java and JavaScript are completely different programming languages.'),
    Question(id: 13, type: 'multiple_choice', question: 'What is a function?', options: ['A reusable block of code', 'A type of variable', 'A database', 'An error message'], correctIndex: 0, explanation: 'A function is a reusable block of code that performs a specific task.'),
    Question(id: 14, type: 'multiple_choice', question: 'Which operator is used for assignment in most languages?', options: ['==', '=', '===', ':='], correctIndex: 1, explanation: 'The single equals sign (=) is used for assignment in most programming languages.'),
    Question(id: 15, type: 'multiple_choice', question: 'What is debugging?', options: ['Adding new features', 'Finding and fixing errors', 'Writing documentation', 'Testing software'], correctIndex: 1, explanation: 'Debugging is the process of finding and fixing errors or bugs in code.'),
    Question(id: 16, type: 'multiple_choice', question: 'What is the output of 5 + 3 * 2?', options: ['16', '11', '13', '10'], correctIndex: 1, explanation: 'Following order of operations, 3*2=6, then 5+6=11.'),
    Question(id: 17, type: 'true_false', question: 'Git is a version control system.', options: ['True', 'False'], correctIndex: 0, explanation: 'Git is a distributed version control system for tracking code changes.'),
    Question(id: 18, type: 'multiple_choice', question: 'What does API stand for?', options: ['Application Programming Interface', 'Advanced Program Integration', 'Automated Process Interface', 'Application Process Integration'], correctIndex: 0, explanation: 'API stands for Application Programming Interface.'),
    Question(id: 19, type: 'multiple_choice', question: 'Which is NOT a programming paradigm?', options: ['Object-Oriented', 'Functional', 'Procedural', 'Alphabetical'], correctIndex: 3, explanation: 'Alphabetical is not a programming paradigm.'),
    Question(id: 20, type: 'multiple_choice', question: 'What is a boolean value?', options: ['A number', 'True or False', 'A text string', 'A decimal'], correctIndex: 1, explanation: 'Boolean values can only be true or false.'),
    // Continue with more questions...
    Question(id: 21, type: 'multiple_choice', question: 'What is the main purpose of a database?', options: ['Store and organize data', 'Create websites', 'Run programs', 'Design graphics'], correctIndex: 0, explanation: 'Databases are designed to store, organize, and retrieve data efficiently.'),
    Question(id: 22, type: 'multiple_choice', question: 'Which protocol is used for secure web browsing?', options: ['HTTP', 'FTP', 'HTTPS', 'SMTP'], correctIndex: 2, explanation: 'HTTPS (HTTP Secure) encrypts data for secure web browsing.'),
    Question(id: 23, type: 'true_false', question: 'RAM is a type of permanent storage.', options: ['True', 'False'], correctIndex: 1, explanation: 'RAM is volatile memory that loses data when power is off.'),
    Question(id: 24, type: 'multiple_choice', question: 'What is an IP address?', options: ['A website name', 'A unique device identifier on a network', 'A programming language', 'A type of software'], correctIndex: 1, explanation: 'An IP address uniquely identifies a device on a network.'),
    Question(id: 25, type: 'multiple_choice', question: 'What does CPU stand for?', options: ['Central Processing Unit', 'Computer Personal Unit', 'Central Program Utility', 'Core Processing Unit'], correctIndex: 0, explanation: 'CPU stands for Central Processing Unit, the brain of the computer.'),
    Question(id: 26, type: 'multiple_choice', question: 'Which is a front-end technology?', options: ['Node.js', 'MySQL', 'React', 'MongoDB'], correctIndex: 2, explanation: 'React is a front-end JavaScript library for building user interfaces.'),
    Question(id: 27, type: 'multiple_choice', question: 'What is cloud computing?', options: ['Weather prediction software', 'Internet-based computing services', 'A type of database', 'A programming language'], correctIndex: 1, explanation: 'Cloud computing delivers computing services over the internet.'),
    Question(id: 28, type: 'true_false', question: 'Linux is an open-source operating system.', options: ['True', 'False'], correctIndex: 0, explanation: 'Linux is an open-source operating system kernel.'),
    Question(id: 29, type: 'multiple_choice', question: 'What is the purpose of a firewall?', options: ['Speed up internet', 'Protect against unauthorized access', 'Store files', 'Create websites'], correctIndex: 1, explanation: 'A firewall monitors and controls network traffic for security.'),
    Question(id: 30, type: 'multiple_choice', question: 'What is machine learning?', options: ['Teaching computers to learn from data', 'Building computer hardware', 'Creating websites', 'Writing documentation'], correctIndex: 0, explanation: 'Machine learning enables computers to learn and improve from experience.'),
    // Zone 2: Networking (Questions 31-90)
    Question(id: 31, type: 'multiple_choice', question: 'What device connects multiple networks?', options: ['Hub', 'Switch', 'Router', 'Modem'], correctIndex: 2, explanation: 'A router connects multiple networks and routes traffic between them.'),
    Question(id: 32, type: 'multiple_choice', question: 'What is bandwidth?', options: ['Physical width of cables', 'Data transfer capacity', 'Computer memory', 'Screen resolution'], correctIndex: 1, explanation: 'Bandwidth is the maximum data transfer rate of a network.'),
    Question(id: 33, type: 'true_false', question: 'Wi-Fi uses radio waves for communication.', options: ['True', 'False'], correctIndex: 0, explanation: 'Wi-Fi uses radio waves to provide wireless network connectivity.'),
    Question(id: 34, type: 'multiple_choice', question: 'What layer of OSI model handles IP addressing?', options: ['Physical', 'Data Link', 'Network', 'Transport'], correctIndex: 2, explanation: 'The Network layer (Layer 3) handles IP addressing and routing.'),
    Question(id: 35, type: 'multiple_choice', question: 'What is DNS?', options: ['Data Network System', 'Domain Name System', 'Digital Network Service', 'Direct Name Server'], correctIndex: 1, explanation: 'DNS translates domain names to IP addresses.'),
    Question(id: 36, type: 'multiple_choice', question: 'Which port is used for HTTP?', options: ['21', '22', '80', '443'], correctIndex: 2, explanation: 'Port 80 is the default port for HTTP traffic.'),
    Question(id: 37, type: 'multiple_choice', question: 'What is a VPN?', options: ['Virtual Private Network', 'Very Private Network', 'Virtual Public Network', 'Verified Private Network'], correctIndex: 0, explanation: 'VPN stands for Virtual Private Network, providing secure connections.'),
    Question(id: 38, type: 'true_false', question: 'TCP is a connectionless protocol.', options: ['True', 'False'], correctIndex: 1, explanation: 'TCP is connection-oriented; UDP is connectionless.'),
    Question(id: 39, type: 'multiple_choice', question: 'What is latency?', options: ['Network speed', 'Time delay in data transmission', 'Data storage', 'Bandwidth limit'], correctIndex: 1, explanation: 'Latency is the time delay for data to travel across a network.'),
    Question(id: 40, type: 'multiple_choice', question: 'What does LAN stand for?', options: ['Large Area Network', 'Local Area Network', 'Long Area Network', 'Linked Area Network'], correctIndex: 1, explanation: 'LAN stands for Local Area Network, covering a small geographic area.'),
    // Continue pattern for remaining questions...
    Question(id: 41, type: 'multiple_choice', question: 'What is a subnet mask?', options: ['Network security tool', 'Divides IP into network and host parts', 'Type of firewall', 'Encryption method'], correctIndex: 1, explanation: 'A subnet mask divides an IP address into network and host portions.'),
    Question(id: 42, type: 'multiple_choice', question: 'Which topology has all devices connected to a central hub?', options: ['Ring', 'Bus', 'Star', 'Mesh'], correctIndex: 2, explanation: 'Star topology connects all devices to a central hub or switch.'),
    Question(id: 43, type: 'true_false', question: 'IPv6 addresses are longer than IPv4 addresses.', options: ['True', 'False'], correctIndex: 0, explanation: 'IPv6 uses 128-bit addresses while IPv4 uses 32-bit addresses.'),
    Question(id: 44, type: 'multiple_choice', question: 'What protocol is used for email sending?', options: ['POP3', 'IMAP', 'SMTP', 'HTTP'], correctIndex: 2, explanation: 'SMTP (Simple Mail Transfer Protocol) is used for sending emails.'),
    Question(id: 45, type: 'multiple_choice', question: 'What is a MAC address?', options: ['Software identifier', 'Hardware address of network interface', 'Website address', 'Email address'], correctIndex: 1, explanation: 'MAC address is a unique hardware identifier for network interfaces.'),
    // Zone 3: Database & Systems
    Question(id: 46, type: 'multiple_choice', question: 'What is a primary key?', options: ['First column in table', 'Unique identifier for records', 'Password field', 'Foreign connection'], correctIndex: 1, explanation: 'A primary key uniquely identifies each record in a database table.'),
    Question(id: 47, type: 'multiple_choice', question: 'What does DBMS stand for?', options: ['Data Basic Management System', 'Database Management System', 'Digital Base Management Service', 'Data Backup Management System'], correctIndex: 1, explanation: 'DBMS stands for Database Management System.'),
    Question(id: 48, type: 'true_false', question: 'NoSQL databases always require a fixed schema.', options: ['True', 'False'], correctIndex: 1, explanation: 'NoSQL databases are schema-flexible, unlike traditional SQL databases.'),
    Question(id: 49, type: 'multiple_choice', question: 'What is normalization?', options: ['Making data abnormal', 'Organizing data to reduce redundancy', 'Encrypting data', 'Compressing files'], correctIndex: 1, explanation: 'Normalization organizes data to minimize redundancy and dependencies.'),
    Question(id: 50, type: 'multiple_choice', question: 'Which command retrieves data from a database?', options: ['INSERT', 'UPDATE', 'SELECT', 'DELETE'], correctIndex: 2, explanation: 'SELECT command retrieves data from database tables.'),
    Question(id: 51, type: 'multiple_choice', question: 'What is a foreign key?', options: ['Key from another country', 'Reference to primary key in another table', 'Encrypted password', 'Backup key'], correctIndex: 1, explanation: 'A foreign key references the primary key of another table.'),
    Question(id: 52, type: 'multiple_choice', question: 'What is ACID in databases?', options: ['A cleaning solution', 'Atomicity, Consistency, Isolation, Durability', 'Advanced Computer Integrated Data', 'Automated Consistent Information Database'], correctIndex: 1, explanation: 'ACID properties ensure reliable database transactions.'),
    Question(id: 53, type: 'true_false', question: 'MongoDB is a relational database.', options: ['True', 'False'], correctIndex: 1, explanation: 'MongoDB is a NoSQL document database, not relational.'),
    Question(id: 54, type: 'multiple_choice', question: 'What is a transaction?', options: ['Money transfer', 'Unit of work in database', 'Data type', 'Table name'], correctIndex: 1, explanation: 'A transaction is a unit of work that must complete entirely or not at all.'),
    Question(id: 55, type: 'multiple_choice', question: 'What is indexing?', options: ['Numbering pages', 'Improving database query speed', 'Creating backups', 'Encrypting data'], correctIndex: 1, explanation: 'Database indexing improves the speed of data retrieval operations.'),
    Question(id: 56, type: 'multiple_choice', question: 'What is a stored procedure?', options: ['Data backup method', 'Precompiled SQL statements', 'Table type', 'User interface'], correctIndex: 1, explanation: 'Stored procedures are precompiled SQL statements stored in the database.'),
    Question(id: 57, type: 'multiple_choice', question: 'What is data warehousing?', options: ['Physical storage building', 'Centralized data repository for analysis', 'Cloud backup', 'File compression'], correctIndex: 1, explanation: 'Data warehousing consolidates data from multiple sources for analysis.'),
    Question(id: 58, type: 'true_false', question: 'Views in SQL can be used to simplify complex queries.', options: ['True', 'False'], correctIndex: 0, explanation: 'Views are virtual tables that simplify complex queries.'),
    Question(id: 59, type: 'multiple_choice', question: 'What is data integrity?', options: ['Data speed', 'Accuracy and consistency of data', 'Data size', 'Data format'], correctIndex: 1, explanation: 'Data integrity ensures accuracy and consistency of data over its lifecycle.'),
    Question(id: 60, type: 'multiple_choice', question: 'What is a trigger in SQL?', options: ['Delete button', 'Automatic action on data events', 'Table creation command', 'Query optimizer'], correctIndex: 1, explanation: 'Triggers automatically execute actions in response to database events.'),
  ];

  // BSBA - Business Administration Questions  
  static final List<Question> _bsbaQuestions = [
    Question(id: 1, type: 'multiple_choice', question: 'What is the primary goal of a business?', options: ['Maximize employee count', 'Generate profit', 'Minimize work', 'Avoid competition'], correctIndex: 1, explanation: 'The primary goal of most businesses is to generate profit.'),
    Question(id: 2, type: 'multiple_choice', question: 'What does ROI stand for?', options: ['Return on Investment', 'Rate of Income', 'Revenue of Interest', 'Return on Income'], correctIndex: 0, explanation: 'ROI stands for Return on Investment, measuring investment profitability.'),
    Question(id: 3, type: 'true_false', question: 'Marketing only involves advertising.', options: ['True', 'False'], correctIndex: 1, explanation: 'Marketing includes product, price, place, and promotion (4Ps).'),
    Question(id: 4, type: 'multiple_choice', question: 'What is a SWOT analysis?', options: ['Sales Worksheet', 'Strengths, Weaknesses, Opportunities, Threats', 'Standard Work Order Template', 'System Workflow Overview'], correctIndex: 1, explanation: 'SWOT analyzes internal strengths/weaknesses and external opportunities/threats.'),
    Question(id: 5, type: 'multiple_choice', question: 'What is supply chain management?', options: ['Managing office supplies', 'Overseeing product flow from source to customer', 'Chain store management', 'Supplier payment system'], correctIndex: 1, explanation: 'Supply chain management oversees the flow of goods and services.'),
    Question(id: 6, type: 'multiple_choice', question: 'What is market segmentation?', options: ['Dividing market into distinct groups', 'Measuring market size', 'Market research method', 'Sales territory'], correctIndex: 0, explanation: 'Market segmentation divides a market into distinct customer groups.'),
    Question(id: 7, type: 'true_false', question: 'Equity represents ownership in a company.', options: ['True', 'False'], correctIndex: 0, explanation: 'Equity represents the ownership interest in a company.'),
    Question(id: 8, type: 'multiple_choice', question: 'What is the purpose of a business plan?', options: ['Daily scheduling', 'Outlining business goals and strategies', 'Employee handbook', 'Tax filing'], correctIndex: 1, explanation: 'A business plan outlines goals, strategies, and financial projections.'),
    Question(id: 9, type: 'multiple_choice', question: 'What does B2B mean?', options: ['Back to Back', 'Business to Business', 'Budget to Budget', 'Brand to Brand'], correctIndex: 1, explanation: 'B2B refers to business transactions between companies.'),
    Question(id: 10, type: 'multiple_choice', question: 'What is an entrepreneur?', options: ['Employee', 'Someone who starts and runs a business', 'Manager', 'Investor'], correctIndex: 1, explanation: 'An entrepreneur starts and manages a new business venture.'),
    Question(id: 11, type: 'multiple_choice', question: 'What is working capital?', options: ['Office space', 'Current assets minus current liabilities', 'Employee wages', 'Investment funds'], correctIndex: 1, explanation: 'Working capital measures short-term financial health.'),
    Question(id: 12, type: 'multiple_choice', question: 'What is corporate governance?', options: ['Government regulations', 'System of rules directing companies', 'CEO responsibilities', 'Office management'], correctIndex: 1, explanation: 'Corporate governance is the system of rules and practices for directing companies.'),
    Question(id: 13, type: 'true_false', question: 'A sole proprietorship has multiple owners.', options: ['True', 'False'], correctIndex: 1, explanation: 'A sole proprietorship has only one owner.'),
    Question(id: 14, type: 'multiple_choice', question: 'What is market research?', options: ['Selling products', 'Gathering information about consumers and markets', 'Price setting', 'Product design'], correctIndex: 1, explanation: 'Market research gathers information to understand markets and consumers.'),
    Question(id: 15, type: 'multiple_choice', question: 'What is a stakeholder?', options: ['Someone with interest in a company', 'Stock investor only', 'Employee only', 'Customer only'], correctIndex: 0, explanation: 'Stakeholders include anyone with an interest in the company.'),
    Question(id: 16, type: 'multiple_choice', question: 'What is competitive advantage?', options: ['Having more employees', 'Unique value giving edge over competitors', 'Lower prices only', 'More products'], correctIndex: 1, explanation: 'Competitive advantage is unique value that distinguishes a company.'),
    Question(id: 17, type: 'multiple_choice', question: 'What is cash flow?', options: ['Money in the safe', 'Movement of money in and out', 'Bank balance', 'Profit margin'], correctIndex: 1, explanation: 'Cash flow is the movement of money in and out of a business.'),
    Question(id: 18, type: 'true_false', question: 'Liability is what a company owns.', options: ['True', 'False'], correctIndex: 1, explanation: 'Liability is what a company owes; assets are what it owns.'),
    Question(id: 19, type: 'multiple_choice', question: 'What is brand equity?', options: ['Brand cost', 'Commercial value of brand perception', 'Logo design', 'Trademark fee'], correctIndex: 1, explanation: 'Brand equity is the commercial value derived from consumer perception.'),
    Question(id: 20, type: 'multiple_choice', question: 'What is a mission statement?', options: ['Daily goals', 'Summary of company purpose and values', 'Financial report', 'Employee handbook'], correctIndex: 1, explanation: 'A mission statement declares a company\'s purpose and values.'),
    // More business questions...
    Question(id: 21, type: 'multiple_choice', question: 'What is human resource management?', options: ['Computer systems', 'Managing employee-related functions', 'Physical resources', 'Financial planning'], correctIndex: 1, explanation: 'HRM manages recruitment, training, and employee relations.'),
    Question(id: 22, type: 'multiple_choice', question: 'What is break-even analysis?', options: ['Calculating when revenue equals costs', 'Measuring losses', 'Employee evaluation', 'Market research'], correctIndex: 0, explanation: 'Break-even analysis determines when total revenue equals total costs.'),
    Question(id: 23, type: 'true_false', question: 'Franchising involves licensing business models.', options: ['True', 'False'], correctIndex: 0, explanation: 'Franchising licenses a business model and brand to franchisees.'),
    Question(id: 24, type: 'multiple_choice', question: 'What is gross profit?', options: ['Total sales', 'Revenue minus cost of goods sold', 'Net income', 'Operating expenses'], correctIndex: 1, explanation: 'Gross profit is revenue minus the cost of goods sold.'),
    Question(id: 25, type: 'multiple_choice', question: 'What is outsourcing?', options: ['Internal hiring', 'Contracting work to external parties', 'Selling assets', 'Inventory management'], correctIndex: 1, explanation: 'Outsourcing contracts business functions to external providers.'),
    Question(id: 26, type: 'multiple_choice', question: 'What is a target market?', options: ['All consumers', 'Specific group of potential customers', 'Competitor customers', 'Past customers'], correctIndex: 1, explanation: 'A target market is a specific group a business aims to reach.'),
    Question(id: 27, type: 'multiple_choice', question: 'What is diversification?', options: ['Focusing on one product', 'Expanding into new markets or products', 'Reducing staff', 'Cutting costs'], correctIndex: 1, explanation: 'Diversification expands a company into new products or markets.'),
    Question(id: 28, type: 'true_false', question: 'An LLC provides liability protection to owners.', options: ['True', 'False'], correctIndex: 0, explanation: 'LLC (Limited Liability Company) protects owners from personal liability.'),
    Question(id: 29, type: 'multiple_choice', question: 'What is organizational culture?', options: ['Office decoration', 'Shared values and practices in an organization', 'Corporate structure', 'Management style'], correctIndex: 1, explanation: 'Organizational culture encompasses shared values, beliefs, and behaviors.'),
    Question(id: 30, type: 'multiple_choice', question: 'What is strategic planning?', options: ['Daily scheduling', 'Setting long-term goals and strategies', 'Budget creation', 'Staff meetings'], correctIndex: 1, explanation: 'Strategic planning defines long-term direction and resource allocation.'),
    Question(id: 31, type: 'multiple_choice', question: 'What is a balance sheet?', options: ['Financial statement showing assets and liabilities', 'Profit report', 'Sales forecast', 'Tax form'], correctIndex: 0, explanation: 'A balance sheet shows assets, liabilities, and equity at a point in time.'),
    Question(id: 32, type: 'multiple_choice', question: 'What is leadership?', options: ['Following orders', 'Guiding and influencing others', 'Managing budgets', 'Technical skills'], correctIndex: 1, explanation: 'Leadership involves guiding and motivating others toward goals.'),
    Question(id: 33, type: 'true_false', question: 'Fixed costs change with production volume.', options: ['True', 'False'], correctIndex: 1, explanation: 'Fixed costs remain constant regardless of production volume.'),
    Question(id: 34, type: 'multiple_choice', question: 'What is e-commerce?', options: ['Electric commerce', 'Buying and selling online', 'Email marketing', 'Electronic manufacturing'], correctIndex: 1, explanation: 'E-commerce is conducting business transactions electronically online.'),
    Question(id: 35, type: 'multiple_choice', question: 'What is market penetration?', options: ['Entering new markets', 'Increasing share in existing markets', 'Product development', 'Market research'], correctIndex: 1, explanation: 'Market penetration increases market share in existing markets.'),
    Question(id: 36, type: 'multiple_choice', question: 'What is customer retention?', options: ['Finding new customers', 'Keeping existing customers', 'Customer surveys', 'Price discounts'], correctIndex: 1, explanation: 'Customer retention focuses on keeping existing customers loyal.'),
    Question(id: 37, type: 'multiple_choice', question: 'What is depreciation?', options: ['Asset value increase', 'Decrease in asset value over time', 'Profit reduction', 'Tax payment'], correctIndex: 1, explanation: 'Depreciation is the decrease in asset value over time.'),
    Question(id: 38, type: 'true_false', question: 'A partnership requires a formal agreement.', options: ['True', 'False'], correctIndex: 1, explanation: 'Partnerships can be formed verbally, though written agreements are recommended.'),
    Question(id: 39, type: 'multiple_choice', question: 'What is benchmarking?', options: ['Setting standards', 'Comparing practices against industry leaders', 'Creating budgets', 'Goal setting'], correctIndex: 1, explanation: 'Benchmarking compares business practices to industry best practices.'),
    Question(id: 40, type: 'multiple_choice', question: 'What is an income statement?', options: ['Bank statement', 'Report showing revenue and expenses', 'Tax return', 'Balance sheet'], correctIndex: 1, explanation: 'An income statement shows revenues, expenses, and profit over a period.'),
    // Continue with more questions to reach 60...
    Question(id: 41, type: 'multiple_choice', question: 'What is inventory management?', options: ['Office organization', 'Overseeing stock levels and orders', 'Employee scheduling', 'Financial planning'], correctIndex: 1, explanation: 'Inventory management controls stock levels to meet demand efficiently.'),
    Question(id: 42, type: 'multiple_choice', question: 'What is quality control?', options: ['Price management', 'Ensuring products meet standards', 'Marketing strategy', 'Customer service'], correctIndex: 1, explanation: 'Quality control ensures products or services meet defined standards.'),
    Question(id: 43, type: 'true_false', question: 'Profit margin is calculated as profit divided by revenue.', options: ['True', 'False'], correctIndex: 0, explanation: 'Profit margin = (Profit / Revenue) × 100%.'),
    Question(id: 44, type: 'multiple_choice', question: 'What is delegation?', options: ['Avoiding work', 'Assigning tasks to others', 'Making decisions alone', 'Following instructions'], correctIndex: 1, explanation: 'Delegation assigns responsibility and authority to others.'),
    Question(id: 45, type: 'multiple_choice', question: 'What is a value proposition?', options: ['Price offer', 'Promise of value to customers', 'Financial projection', 'Mission statement'], correctIndex: 1, explanation: 'A value proposition communicates the unique value offered to customers.'),
    Question(id: 46, type: 'multiple_choice', question: 'What is business ethics?', options: ['Legal compliance only', 'Moral principles guiding business conduct', 'Profit maximization', 'Competition strategy'], correctIndex: 1, explanation: 'Business ethics applies moral principles to business decisions.'),
    Question(id: 47, type: 'multiple_choice', question: 'What is a merger?', options: ['Company closure', 'Combining two companies into one', 'Hostile takeover', 'Franchise agreement'], correctIndex: 1, explanation: 'A merger joins two companies into a single entity.'),
    Question(id: 48, type: 'true_false', question: 'Variable costs remain constant per unit.', options: ['True', 'False'], correctIndex: 0, explanation: 'Variable costs change in total but remain constant per unit produced.'),
    Question(id: 49, type: 'multiple_choice', question: 'What is customer segmentation?', options: ['Customer complaints', 'Dividing customers into groups', 'Pricing strategy', 'Product development'], correctIndex: 1, explanation: 'Customer segmentation divides customers into groups with similar needs.'),
    Question(id: 50, type: 'multiple_choice', question: 'What is return on equity (ROE)?', options: ['Investor return', 'Net income divided by shareholder equity', 'Stock price', 'Dividend payment'], correctIndex: 1, explanation: 'ROE measures profitability relative to shareholder equity.'),
    Question(id: 51, type: 'multiple_choice', question: 'What is operations management?', options: ['IT support', 'Managing production and delivery processes', 'Marketing', 'Human resources'], correctIndex: 1, explanation: 'Operations management oversees production and delivery of products/services.'),
    Question(id: 52, type: 'multiple_choice', question: 'What is a startup?', options: ['Established corporation', 'New business venture in early stages', 'Franchise location', 'Government agency'], correctIndex: 1, explanation: 'A startup is a new company in its early development stages.'),
    Question(id: 53, type: 'true_false', question: 'A sole proprietor has unlimited liability.', options: ['True', 'False'], correctIndex: 0, explanation: 'Sole proprietors are personally liable for all business debts.'),
    Question(id: 54, type: 'multiple_choice', question: 'What is a budget?', options: ['Expense report', 'Financial plan for income and expenses', 'Profit statement', 'Tax return'], correctIndex: 1, explanation: 'A budget is a financial plan estimating revenue and expenses.'),
    Question(id: 55, type: 'multiple_choice', question: 'What is networking in business?', options: ['Computer systems', 'Building professional relationships', 'Internet connection', 'Cable management'], correctIndex: 1, explanation: 'Business networking builds professional relationships and connections.'),
    Question(id: 56, type: 'multiple_choice', question: 'What is customer acquisition cost?', options: ['Product cost', 'Cost to gain a new customer', 'Service fee', 'Subscription price'], correctIndex: 1, explanation: 'Customer acquisition cost is the expense of gaining new customers.'),
    Question(id: 57, type: 'multiple_choice', question: 'What is vertical integration?', options: ['Company restructuring', 'Controlling multiple production stages', 'Horizontal expansion', 'Market diversification'], correctIndex: 1, explanation: 'Vertical integration controls multiple stages of production/distribution.'),
    Question(id: 58, type: 'true_false', question: 'Gross margin is the same as net profit.', options: ['True', 'False'], correctIndex: 1, explanation: 'Gross margin is revenue minus COGS; net profit deducts all expenses.'),
    Question(id: 59, type: 'multiple_choice', question: 'What is market share?', options: ['Stock ownership', 'Company portion of total market sales', 'Marketing budget', 'Customer count'], correctIndex: 1, explanation: 'Market share is a company\'s portion of total market sales.'),
    Question(id: 60, type: 'multiple_choice', question: 'What is lean management?', options: ['Weight loss program', 'Minimizing waste while maximizing value', 'Small team management', 'Cost cutting'], correctIndex: 1, explanation: 'Lean management focuses on eliminating waste and maximizing value.'),
  ];

  // Placeholder for other programs - same structure
  static final List<Question> _bsedQuestions = _generateEducationQuestions('BSED', 'secondary education');
  static final List<Question> _beedQuestions = _generateEducationQuestions('BEED', 'elementary education');
  static final List<Question> _bsaQuestions = _generateAccountingQuestions();
  static final List<Question> _bshmQuestions = _generateHospitalityQuestions();
  static final List<Question> _bscsQuestions = _generateComputerScienceQuestions();
  static final List<Question> _bscpeQuestions = _generateComputerEngineeringQuestions();
  static final List<Question> _ahmQuestions = _generateHospitalityQuestions();

  // Helper methods to generate questions for each program
  static List<Question> _generateEducationQuestions(String program, String focus) {
    return List.generate(60, (i) => Question(
      id: i + 1,
      type: i % 3 == 0 ? 'true_false' : 'multiple_choice',
      question: _getEducationQuestion(i, focus),
      options: i % 3 == 0 ? ['True', 'False'] : _getEducationOptions(i),
      correctIndex: i % 3 == 0 ? (i % 2) : (i % 4),
      explanation: 'This is a fundamental concept in $focus pedagogy.',
      points: 10 + (i ~/ 20) * 5,
    ));
  }

  static String _getEducationQuestion(int index, String focus) {
    final questions = [
      'What is the primary purpose of lesson planning?',
      'Which teaching method encourages student-centered learning?',
      'Formative assessment occurs during instruction.',
      'What is differentiated instruction?',
      'Which theory emphasizes learning through experience?',
      'Bloom\'s Taxonomy classifies cognitive skills.',
      'What is classroom management?',
      'Which approach uses real-world problems?',
      'Summative assessment measures final achievement.',
      'What is scaffolding in education?',
      'Which intelligence involves musical ability?',
      'Constructivism suggests learners build knowledge.',
      'What is inclusive education?',
      'Which method uses peer teaching?',
      'Rubrics provide clear assessment criteria.',
      'What is curriculum development?',
      'Which theory focuses on behavior modification?',
      'Metacognition involves thinking about thinking.',
      'What is student engagement?',
      'Which approach integrates technology in learning?',
    ];
    return questions[index % questions.length];
  }

  static List<String> _getEducationOptions(int index) {
    final optionSets = [
      ['Guide instruction', 'Waste time', 'Confuse students', 'Skip lessons'],
      ['Lecture only', 'Inquiry-based learning', 'Rote memorization', 'Testing'],
      ['Adjusting teaching to student needs', 'Same instruction for all', 'Grading on curve', 'Extra homework'],
      ['Behaviorism', 'Experiential learning', 'Cognitivism', 'Humanism'],
      ['Organizing student behavior', 'Physical arrangement only', 'Discipline only', 'Grading system'],
      ['Problem-based learning', 'Lecture method', 'Silent reading', 'Memorization'],
      ['Temporary support for learning', 'Permanent help', 'No assistance', 'Direct instruction'],
      ['Logical-mathematical', 'Musical', 'Linguistic', 'Spatial'],
      ['Education for all abilities', 'Gifted only', 'Special education only', 'Regular classes'],
      ['Cooperative learning', 'Individual work', 'Competition', 'Testing'],
    ];
    return optionSets[index % optionSets.length];
  }

  static List<Question> _generateAccountingQuestions() {
    return List.generate(60, (i) => Question(
      id: i + 1,
      type: i % 3 == 0 ? 'true_false' : 'multiple_choice',
      question: _getAccountingQuestion(i),
      options: i % 3 == 0 ? ['True', 'False'] : _getAccountingOptions(i),
      correctIndex: i % 3 == 0 ? (i % 2) : (i % 4),
      explanation: 'This is a core accounting principle.',
      points: 10 + (i ~/ 20) * 5,
    ));
  }

  static String _getAccountingQuestion(int index) {
    final questions = [
      'What is double-entry bookkeeping?',
      'Which financial statement shows profitability?',
      'Assets equal liabilities plus equity.',
      'What is the purpose of an audit?',
      'Which account type normally has a debit balance?',
      'GAAP stands for Generally Accepted Accounting Principles.',
      'What is accounts receivable?',
      'Which ratio measures liquidity?',
      'Depreciation is a non-cash expense.',
      'What is accrual accounting?',
      'Which costs are directly tied to production?',
      'Revenue recognition follows matching principle.',
      'What is a trial balance?',
      'Which method values inventory at recent costs?',
      'Internal controls prevent fraud.',
      'What is cost accounting?',
      'Which variance shows material usage differences?',
      'Amortization applies to intangible assets.',
      'What is forensic accounting?',
      'Which report shows cash movements?',
    ];
    return questions[index % questions.length];
  }

  static List<String> _getAccountingOptions(int index) {
    final optionSets = [
      ['Every transaction affects two accounts', 'Single entry system', 'Cash only recording', 'No recording'],
      ['Balance sheet', 'Income statement', 'Cash flow statement', 'Equity statement'],
      ['Verify financial accuracy', 'Create budgets', 'Train staff', 'Market products'],
      ['Assets', 'Liabilities', 'Revenue', 'Equity'],
      ['Money owed to business', 'Money owed by business', 'Cash on hand', 'Inventory'],
      ['Current ratio', 'Profit margin', 'Return on equity', 'Debt ratio'],
      ['Recording when earned/incurred', 'Cash basis only', 'Annual recording', 'Monthly only'],
      ['Direct costs', 'Fixed costs', 'Sunk costs', 'Opportunity costs'],
      ['Verify debits equal credits', 'Calculate profit', 'Create budget', 'Audit report'],
      ['LIFO', 'FIFO', 'Average cost', 'Specific identification'],
    ];
    return optionSets[index % optionSets.length];
  }

  static List<Question> _generateHospitalityQuestions() {
    return List.generate(60, (i) => Question(
      id: i + 1,
      type: i % 3 == 0 ? 'true_false' : 'multiple_choice',
      question: _getHospitalityQuestion(i),
      options: i % 3 == 0 ? ['True', 'False'] : _getHospitalityOptions(i),
      correctIndex: i % 3 == 0 ? (i % 2) : (i % 4),
      explanation: 'This is essential knowledge in hospitality management.',
      points: 10 + (i ~/ 20) * 5,
    ));
  }

  static String _getHospitalityQuestion(int index) {
    final questions = [
      'What is the front office in a hotel?',
      'Which department handles housekeeping?',
      'Guest satisfaction is the primary goal of hospitality.',
      'What is RevPAR?',
      'Which service style involves tableside cooking?',
      'Concierge services help guests with special requests.',
      'What is yield management?',
      'Which factor most affects guest loyalty?',
      'Food cost percentage affects profitability.',
      'What is a banquet service?',
      'Which type of menu changes daily?',
      'HACCP ensures food safety.',
      'What is turndown service?',
      'Which reservation system is most common?',
      'Upselling increases revenue per guest.',
      'What is F&B in hospitality?',
      'Which rating system uses stars?',
      'SOP stands for Standard Operating Procedure.',
      'What is occupancy rate?',
      'Which amenity is most valued by business travelers?',
    ];
    return questions[index % questions.length];
  }

  static List<String> _getHospitalityOptions(int index) {
    final optionSets = [
      ['Guest check-in and services', 'Kitchen area', 'Storage room', 'Staff lounge'],
      ['Front office', 'Rooms division', 'F&B', 'Security'],
      ['Revenue per available room', 'Room reservation', 'Revenue report', 'Rate card'],
      ['Buffet', 'French service', 'American service', 'Counter service'],
      ['Pricing strategy for maximum revenue', 'Farm production', 'Staff scheduling', 'Menu planning'],
      ['Service quality', 'Room size', 'Location only', 'Price only'],
      ['Catering for events', 'Room service', 'Bar service', 'Pool service'],
      ['Table d\'hote', 'A la carte', 'Du jour', 'Prix fixe'],
      ['Evening bed preparation', 'Wake-up call', 'Room cleaning', 'Laundry'],
      ['OTA', 'POS', 'CRM', 'PMS'],
    ];
    return optionSets[index % optionSets.length];
  }

  static List<Question> _generateComputerScienceQuestions() {
    return List.generate(60, (i) => Question(
      id: i + 1,
      type: i % 3 == 0 ? 'true_false' : 'multiple_choice',
      question: _getCSQuestion(i),
      options: i % 3 == 0 ? ['True', 'False'] : _getCSOptions(i),
      correctIndex: i % 3 == 0 ? (i % 2) : (i % 4),
      explanation: 'This is a fundamental computer science concept.',
      points: 10 + (i ~/ 20) * 5,
    ));
  }

  static String _getCSQuestion(int index) {
    final questions = [
      'What is the time complexity of binary search?',
      'Which data structure uses LIFO?',
      'Recursion involves a function calling itself.',
      'What is polymorphism?',
      'Which sorting algorithm is fastest on average?',
      'Big O notation describes algorithm efficiency.',
      'What is a linked list?',
      'Which design pattern ensures single instance?',
      'Encapsulation hides internal implementation.',
      'What is dynamic programming?',
      'Which tree structure is self-balancing?',
      'Abstraction simplifies complex systems.',
      'What is a hash function?',
      'Which paradigm treats computation as math functions?',
      'Inheritance allows code reuse.',
      'What is a deadlock?',
      'Which search explores neighbors first?',
      'Threads share memory within a process.',
      'What is garbage collection?',
      'Which complexity class is polynomial?',
    ];
    return questions[index % questions.length];
  }

  static List<String> _getCSOptions(int index) {
    final optionSets = [
      ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
      ['Queue', 'Stack', 'Array', 'Tree'],
      ['Same behavior with different types', 'Single type only', 'No types', 'Inheritance only'],
      ['Bubble sort', 'Quick sort', 'Selection sort', 'Insertion sort'],
      ['Elements with pointers', 'Fixed size array', 'Hash table', 'Binary tree'],
      ['Factory', 'Singleton', 'Observer', 'Strategy'],
      ['Breaking problems into subproblems', 'Static analysis', 'Random search', 'Brute force'],
      ['Binary tree', 'AVL tree', 'Linked list', 'Array'],
      ['Maps keys to values', 'Sorts data', 'Stores files', 'Encrypts data'],
      ['Object-oriented', 'Functional', 'Procedural', 'Logical'],
    ];
    return optionSets[index % optionSets.length];
  }

  static List<Question> _generateComputerEngineeringQuestions() {
    return List.generate(60, (i) => Question(
      id: i + 1,
      type: i % 3 == 0 ? 'true_false' : 'multiple_choice',
      question: _getCpEQuestion(i),
      options: i % 3 == 0 ? ['True', 'False'] : _getCpEOptions(i),
      correctIndex: i % 3 == 0 ? (i % 2) : (i % 4),
      explanation: 'This is essential computer engineering knowledge.',
      points: 10 + (i ~/ 20) * 5,
    ));
  }

  static String _getCpEQuestion(int index) {
    final questions = [
      'What is a microprocessor?',
      'Which gate outputs 1 only when all inputs are 1?',
      'Binary uses base 2 number system.',
      'What is embedded systems?',
      'Which memory is volatile?',
      'RISC uses reduced instruction set.',
      'What is a bus in computer architecture?',
      'Which component executes instructions?',
      'Cache memory improves performance.',
      'What is an interrupt?',
      'Which register holds memory address?',
      'Pipelining increases instruction throughput.',
      'What is a flip-flop?',
      'Which architecture separates data and instruction memory?',
      'Assembly is low-level programming language.',
      'What is firmware?',
      'Which protocol is used for serial communication?',
      'FPGA is reconfigurable hardware.',
      'What is DMA?',
      'Which component converts digital to analog?',
    ];
    return questions[index % questions.length];
  }

  static List<String> _getCpEOptions(int index) {
    final optionSets = [
      ['CPU on a chip', 'Memory unit', 'Input device', 'Output device'],
      ['OR', 'AND', 'NOT', 'XOR'],
      ['Computers in devices', 'Desktop only', 'Servers only', 'Networks'],
      ['RAM', 'ROM', 'Flash', 'Hard drive'],
      ['Data pathway', 'Storage unit', 'Processor', 'Power supply'],
      ['ALU', 'Memory', 'Register', 'Bus'],
      ['Signal to CPU', 'Memory type', 'Bus type', 'Instruction'],
      ['MAR', 'MDR', 'PC', 'IR'],
      ['Memory storage element', 'Logic gate', 'Processor', 'Bus'],
      ['Harvard', 'Von Neumann', 'RISC', 'CISC'],
    ];
    return optionSets[index % optionSets.length];
  }
}
