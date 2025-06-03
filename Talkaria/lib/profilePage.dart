import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String token;
  final int userId;
  final String username;
  const ProfilePage({super.key, required this.token, this.userId = 0, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  String _formatRole(List roles) {
    if (roles.contains('ROLE_ADMIN')) {
      return 'admin';
    }
    return 'user';
  }

  Map<String, dynamic>? _user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      if (widget.token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token non valide')),
        );
        return;
      }

      // Récupérer les informations de l'utilisateur via l'API
      final response = await http.get(
        Uri.parse('https://std29.beaupeyrat.com/api/users?current=true'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/ld+json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Données brutes: ${response.body}');
          print('Données décodées: $data');
          print('Type de données: ${data.runtimeType}');
          
          if (data is Map<String, dynamic>) {
            print('Clés disponibles: ${data.keys}');
            final members = data['member'] as List<dynamic>;
            
            // Afficher le premier utilisateur pour vérification
            print('Premier utilisateur: ${members[0]}');
            
            // Afficher tous les emails disponibles
            print('Emails disponibles: ${members.map((user) => user['email']).join(', ')}');
            
            // Afficher le token complet
            print('Token complet: ${widget.token}');
            
            // Extraire l'ID de l'utilisateur du token
            String? userId;
            try {
              // Le token est dans le format header.payload.signature
              final parts = widget.token.split('.');
              if (parts.length == 3) {
                // Le payload est la deuxième partie
                final payload = parts[1];
                // Ajouter les padding manquants
                final paddedPayload = payload + '=' * (4 - payload.length % 4);
                // Décoder le payload
                final decoded = base64.decode(paddedPayload);
                final payloadData = json.decode(utf8.decode(decoded));
                userId = payloadData['sub']; // Le 'sub' est l'ID de l'utilisateur dans JWT
                print('ID utilisateur extrait du token: $userId');
              }
            } catch (e) {
              print('Erreur lors de l\'extraction de l\'ID: $e');
              userId = null;
            }
            
            // Convertir l'ID en entier
            final userIdInt = userId != null ? int.tryParse(userId) : null;
            
            // Utiliser l'email pour trouver l'utilisateur
            print('Recherche du profil pour username: \'${widget.username}\'');
            print('Emails dans l\'API: ' + members.map((u) => u['email']).join(', '));
            print('UserIdentifiers dans l\'API: ' + members.map((u) => u['userIdentifier']).join(', '));
            print('Usernames dans l\'API: ' + members.map((u) => u['username']).join(', '));
            final currentUser = members.firstWhere(
              (user) => user['email'] == widget.username
                     || user['userIdentifier'] == widget.username
                     || user['username'] == widget.username,
              orElse: () => null,
            );

            if (currentUser != null) {
              setState(() {
                _user = {
                  'email': currentUser['email'] ?? 'Email non disponible',
                  'createdAt': currentUser['createdAt'] ?? 'Date non disponible',
                  'roles': (currentUser['roles'] as List<dynamic>?)?.cast<String>() ?? ['ROLE_USER'],
                };
                isLoading = false;
              });
            } else {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Utilisateur non trouvé')),
              );
            }
          } else {
            print('Données non Map');
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Format de données invalide')),
            );
          }
        } catch (e) {
          print('Erreur de décodage: $e');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur de décodage des données')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur ${response.statusCode} : ${response.body}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF4F4F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Erreur lors du chargement du profil'))
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_circle, size: 70, color: Colors.deepPurple),
                                  const SizedBox(height: 16),
                                  Text(
                                    _user!['email'],
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Créé le: ${_formatDate(_user!['createdAt'])}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.verified_user, size: 18, color: Colors.grey[700]),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Rôle: ',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                      ),
                                      Text(
                                        _formatRole(_user!['roles']),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.logout, color: Colors.white),
                              label: const Text('Se déconnecter', style: TextStyle(color: Colors.white, fontSize: 16)),
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
