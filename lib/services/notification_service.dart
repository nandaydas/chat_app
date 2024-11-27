import 'dart:developer';
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    log('Getting server key token...');
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "jasda-care-family",
          "private_key_id": "b309eb2c3cebc04b420c6d1530e60c64783485fb",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDk7qlLKIerjtHS\nTsFqaXr7g1xFdIJ7RPV15K07+YMckdTV0W3yTl8b8iYfAH6IFHxWVUc2Huf1caC8\n2NVJ4PYVQrX4yNYbS6sj7tF3vt0HjyD4wwV2buN//4/R7D17xgtsjmJbyE10IG1a\nhkiDRL91ovqyCRuU1Ejo76YTLBXHyZ9mBQTIXF429cLtT+Yw9Tdab2mOdrcw2/Nv\nSZDTF6onw9qv1BP5iIDkzCAUULOSBePBMqu2gvuGDih3BQVLDPjXmwLEYEWnQyPs\nl96rjKJ8HzP0s3GwvqbSqY5ggsq2eBYocTT+xreKim8y+9dxJHJgEpt1jjBnjmeb\nacQC0IkNAgMBAAECggEAJsQyV0eQ99Bqv/f1oTkk6ffT1XAWE105SqIzYptNJDae\nqal5+oTibqdJ5MiO5KjBaFYvBZ9krKe17hyyu3y0dyOxkGQj+4HMBHzxrBseLyRB\n01Yk8+nxrNBgMI5WWAIQl6yhw8SOtxoxolloaJAo8rjrRmAr8z8ibI1+XDNEKe0s\nwpas8m0hBWr5XQBJMgs25Y1wnaFBdLqpTLgVKOPofghQbZB/A2joUxr14ff1NXQO\nC657p81DHnBsnEimuUzhOtwdwPRN1eW7NXD2Hc1+ObIphvEpKcVRXVoTk5ln7V0P\nIfnlECpQdmn1oM1NjzhHIfXnNz4Nye4FFsuEMi/SSQKBgQD5JtbVBXP0kLctHYGx\nsw74AuZInan2sJADdrGDHO9PGtcSdr/yHkvM+fnDnvi4TfFg8DzBipQ7Sa9tPTdS\n+Rt8lcWmE1grsxk9U95NL1uzAjVfcK04Z6ycVl2wo0Liw0Crc/wNZfJ4PvlKYK+V\n/9FTu5dDNMzYFBvUkSb3pQi0GQKBgQDrOYwv0RHX89U6dVMZekYqGhe9uAnxY0fN\nRLbl3lEnVvoR7tY9XelzoglTexvIOwmJWzR0g4jFMNRUXKiZApf54OgG6xSNIFe1\n+jMPGaSr4iXHLh8ZkxtYfa6IyFEYv9nHeJQz9ELKaVT4faQPd0S0rOOhQkzjBuJm\ni/N651g7FQKBgQCxUZT/0nuuCPh04VUWVOtIUzf1YlA+Q3abIHRBbexbDi0W9PCy\nriEgZp/9OzykXsR1S0TSMYBBmbWCN1kScju/tRAPnCDaKQLDhNbnc9b9VYsKu7Rs\nOky8jzLqrabCoFd8LnWqS23/akIdTyZnyML/priGmiNXfSg5ZnynLws8sQKBgQC0\ngQWtj98Ee61N3ch2DZmYJ0u+n2Kp5MitoSRFAzP9X0YoysGGd/F0dYx4jkkEfyFT\nUTTQkDs9LrpRPoV2XUIoU0laPb0YixAjqirSVJhD+heJYEAnTPa4EkID3sw0lMxW\nwJXhxHgYgXnd8fQaliiYCO/oyEreEGNd09l0n+DZ/QKBgELjZ8c5886TuEFEiw1o\n5qc6lGcRdMS/frlKD9FglN78FQKuVOEUt1kZNB+B0KMjaURM/pZh1xzDYzDHbIY7\n5eVQU2ulgmeXaI60pisAkrxnS3UBy3YEmI8ASRlVSkQdGdPHazviDyJr4PBsqYEV\nMvu+4y26Re8lxgbXfT65IZHP\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-9xqqh@jasda-care-family.iam.gserviceaccount.com",
          "client_id": "115716823447475273107",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-9xqqh%40jasda-care-family.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);

    final String accessServerKey = client.credentials.accessToken.data;

    log(accessServerKey);
    return accessServerKey;
  }
}
