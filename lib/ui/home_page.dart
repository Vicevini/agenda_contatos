import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {
  telavazia,
  telacontatos,
  telacarregamento,
  refresh,
  ordernameaz,
  ordernameza,
  ordermailaz,
  ordermailza,
  orderphoneon,
  orderphoneno
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts;

  @override
  void initState() {
    super.initState();
    print("run");
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    // print("Build $context");
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.ordernameaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.ordernameza,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar emails de A-Z"),
                value: OrderOptions.ordermailaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar emails de Z-A"),
                value: OrderOptions.ordermailza,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar numeros de 0-9"),
                value: OrderOptions.orderphoneon,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar emails de 9-0"),
                value: OrderOptions.orderphoneno,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Recarregar seus contatos"),
                value: OrderOptions.refresh,
              ),

              const PopupMenuItem<OrderOptions>(
                child: Text("Show loading screen"),
                value: OrderOptions.telacarregamento,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Show empty screen"),
                value: OrderOptions.telavazia,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Show contact grid screen"),
                value: OrderOptions.telacontatos,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: gerenciaTela(context),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        child: Text(
                          "Ligar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        child: Text(
                          "Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
              contact: contact,
            )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() async {
    print("Pegando dados from DataBase");
    var duration = Duration(seconds: 5);
    var delay = Future.delayed(duration, () {
      return print("Dados recebidos com sucesso");
    });
    // setState(() {
    //   contacts = null;
    // });
    await delay;
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.ordernameaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.ordernameza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      case OrderOptions.ordermailaz:
        contacts.sort((a, b) {
          return a.email.toLowerCase().compareTo(b.email.toLowerCase());
        });
        break;
      case OrderOptions.ordermailza:
        contacts.sort((a, b) {
          return b.email.toLowerCase().compareTo(a.email.toLowerCase());
        });
        break;
      case OrderOptions.orderphoneon:
        contacts.sort((a, b) {
          return a.phone.compareTo(b.phone);
        });
        break;
      case OrderOptions.orderphoneno:
        contacts.sort((a, b) {
          return b.phone.compareTo(a.phone);
        });
        break;

      case OrderOptions.refresh:
        recarregaContatos();
        break;

      case OrderOptions.telacarregamento:
        trocaTelaCarregando();
        break;

      case OrderOptions.telavazia:
        trocaTelaVazia();
        break;

      case OrderOptions.telacontatos:
        trocaTelaLista();
        break;
    }
    setState(() {});
  }

  Widget telaCarregando(BuildContext context) {
    var tweenAnimationBuilder = TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 5),
      builder: (context, value, _) => SizedBox(
        width: 150,
        height: 150,
        child: CircularProgressIndicator(
          value: value,
          color: Colors.red,
          backgroundColor: Colors.blueGrey,
          strokeWidth: 5,
        ),
      ),
    );
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          tweenAnimationBuilder,
        ],
      ),
    );
  }

  Widget telaVazia(BuildContext context) {
    return Center(
      child: Text(
        "Lista de contatos vazia",
        style: TextStyle(color: Colors.red, fontSize: 18),
      ),
    );
  }

  Widget gerenciaTela(BuildContext context) {
    //print("Gerencia tela");
    if (contacts == null) {
      // print("Tela carregando");
      return telaCarregando(context);
    }
    isNotEmpty(contacts);
    var var2 = isNotEmpty(contacts);
    // print("Var 2 $var2");
    if (var2 != true) {
      // print("Tela vazia");
      return telaVazia(context);
    } else {
      // print("Tela Lista");
      return telaLista();
    }
    // print("$contacts");
    // return telaCarregando(context);
  }

  telaLista() {
    return ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        });
  }

  isEmpty(List lista) {
    if (lista.length == 0) {
      print("true");
    }
  }

  bool isNotEmpty(List lista) {
    var isEmpty = lista.isEmpty;
    if (isEmpty != true) {
      return true; //return !lista.isEmpty
    }
    return false;
  }

  recarregaContatos() {
    setState(() {
      contacts = null;
    });
    print("Reload executado");
    _getAllContacts();
  }

  deletaContatos() {
    setState(() {});
  }

  trocaTelaCarregando() {
    setState(() {
      contacts = null;
    });
  }

  trocaTelaVazia() {
    setState(() {
      contacts = [];
    });
  }

  trocaTelaLista() {
    // Criar um objeto contato

    criaLista();

    Contact a = Contact();

    // Atribui esse objeto a lista

    contacts = criaLista();


  }

  List criaLista() {
    print("Criando Lista");

    return [Contact()];
    // Contact pessoa = Contact();
    //
    // List agenda;
    //
    // agenda = [pessoa];
    //
    // return agenda;
  }
}
