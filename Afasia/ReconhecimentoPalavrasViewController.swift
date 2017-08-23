//
//  ReconhecimentoPalavrasViewController.swift
//  Afasia
//
//  Created by Edson  Jr on 16/08/17.
//  Copyright © 2017 Edson  Jr. All rights reserved.
//

import UIKit

class ReconhecimentoPalavrasViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    
    //Mark: View componentes
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet var configuracoesPopOver: UIView!
    @IBOutlet weak var configuracoesPopOverPicker: UIPickerView!
    @IBOutlet weak var swipeView: UIView!
    
    @IBOutlet weak var errouBTN: UIButton!
    @IBOutlet weak var acertouBTN: UIButton!
    
    
    
    //Mark: Mensagem de debug
    private let dbgmsg = "[EXEC1]: "
    
    
    //Mark: Configuracoes do picker
    var configExecPickerData: [String] = ["Todas","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","Y","Z"]
    
    
    
    
    //Mark: enum para indicar quais os estados possiveis a serem computados no exercicio (acerto, erro, duvida)
    enum estadosDoExercicio1: String {
        case acertou = "acerto"
        case erro = "erro"
        case duvida = "duvida"
    }
    
    
    //Mark: Struct para armazenar se a pessoa acertou, errou ou esta em duvida naquela figura em si
    struct acertoErroDuvidaStruct {
        
        var imagemExec: ImagemExercicio?
        var estado: String?
        
    }
    
    
    
    //Mark: variaveis para computar a quantidade de acertos, erros ou duvidas e controlar o indice de acesso
    var acertos: Int = 0
    var erros: Int = 0
    var duvidas: Int = 0
    
    var estruturaDeAcertosErrosDuvidas: [acertoErroDuvidaStruct]?
    
    var idImagemAtual: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        //adicionando o suporte ao swipe para passar as imagens
        addSwipe()
        //delegate e datasource do UIPickerView
        self.configuracoesPopOverPicker.delegate = self
        self.configuracoesPopOverPicker.dataSource = self
        
        
        //Carregando todas as imagens no vetor de imagens
        carregarTodasImagens(imagens: ImagemExercicioStore.getAllImagensExecs(), qtImagens: 4)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //Mark: Button Actions
    
    //resposnavel por chamar o pop over das configuracoes do 
    @IBAction func configuracoes(_ sender: Any) {
        print(dbgmsg + "Chamando configuracoes")
        callPopover()
    }
    
    
    //responsavel por voltar para a tela anterior
    @IBAction func voltarParaTelaAnterior(_ sender: Any) {
        alertarExercicioEmCurso(irParaFeedback: false)
        
    }
    
    
    
    
    //responsavel por computar acertos
    @IBAction func acertou(_ sender: Any) {
        print(dbgmsg + "Acertou!")
        self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].estado = estadosDoExercicio1.acertou.rawValue
       
        
        //computando acerto
        self.acertos = acertos + 1
        self.duvidas = duvidas - 1
        
        
         //carrega a proxima imagem se possivel
         carregarProximaImagem()
        
        //verificando se ainda restam imagens que nao foram computadas
        if verificarSeTodasImagensForamRespondidas() {
            print(dbgmsg + "Todas imagens ja foram computadas. Va para a tela de feedback")
            alertarConclusaoExercicio()
        }
    
    }
    
    
    
    
    //responsavel por computar os erros
    @IBAction func errou(_ sender: Any) {
        print(dbgmsg + "Errou!")
        self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].estado = estadosDoExercicio1.erro.rawValue
       
        
        //computando erros
        self.erros = erros + 1
        self.duvidas = duvidas - 1
        
        
        //carrega a proxima imagem se possivel
        carregarProximaImagem()
        
        //verificando se ainda restam imagens que nao foram computadas
        if verificarSeTodasImagensForamRespondidas() {
            print(dbgmsg + "Todas imagens ja foram computadas. Va para a tela de feedback")
            alertarConclusaoExercicio()
        }


    
    }
    
    
    
    //responsavel por fechar as configuracoes
    @IBAction func fecharConfiguracoes(_ sender: Any) {
        print(dbgmsg + "Fechando configuracoes")
        removePopover()
        
    }
    
    
    
    
    //responsavel por finalizar o exercicio
    @IBAction func finalizar(_ sender: Any) {
     
        //carregar a tela de feedback de erros e acertos aqui
        print(dbgmsg + "acertos: \(acertos) | erros: \(erros) | duvidas: \(duvidas)")
       alertarExercicioEmCurso(irParaFeedback: true)
        
        
    }
    
    
    //Mark: Funcoes de swipe 
    
    //adicionando suporte ao swipe na swipeView
    func addSwipe() {
        let swipeGestures: [UISwipeGestureRecognizerDirection] = [UISwipeGestureRecognizerDirection.right,UISwipeGestureRecognizerDirection.left]
        for direction in swipeGestures {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ReconhecimentoPalavrasViewController.handleSwipeGesture(_sender:)))
            gesture.direction = direction
            self.swipeView.addGestureRecognizer(gesture)
        }
        
    }

    
    
    
    //implementando comportamento de troca das imagens
    func handleSwipeGesture(_sender: UISwipeGestureRecognizer){
        
        
        if _sender.direction == UISwipeGestureRecognizerDirection.left {
            print(dbgmsg + "Swipe action: esquerda") //avanca as imagens
            self.idImagemAtual = self.idImagemAtual! + 1
            if idImagemAtual! < (self.estruturaDeAcertosErrosDuvidas?.count)! {
                //animacoes de troca ocorrem aqui
                self.ImageView.image = self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].imagemExec?.asset
                
                //se o estado da imagem do exercicio atual for igual ao de duvida, apresente os botoes
                if self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].estado != estadosDoExercicio1.duvida.rawValue {
                    print(dbgmsg + "Acertou ou errou esta imagem")
                    self.errouBTN.isHidden = true
                    self.acertouBTN.isHidden = true
                }else{
                    self.errouBTN.isHidden = false
                    self.acertouBTN.isHidden = false
                }
                
            }else{
                self.idImagemAtual = ((self.estruturaDeAcertosErrosDuvidas?.count)! - 1)
                print(dbgmsg + "Limite maximo de imagens alcancado!")
            }
            
        }else if _sender.direction == UISwipeGestureRecognizerDirection.right {
            print(dbgmsg + "Swipe action: direita") //volta as imagens
            self.idImagemAtual = self.idImagemAtual! - 1
            if idImagemAtual! >= 0 {
                //animacoes de troca podem ocorrer aqui
                self.ImageView.image = self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].imagemExec?.asset
                
                
                //se o estado da imagem do exercicio atual for igual ao de duvida, apresente os botoes
                if self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].estado != estadosDoExercicio1.duvida.rawValue {
                    print(dbgmsg + "Acertou ou errou esta imagem")
                    self.errouBTN.isHidden = true
                    self.acertouBTN.isHidden = true
                }else{
                    self.errouBTN.isHidden = false
                    self.acertouBTN.isHidden = false
                }


                
                
            }else {
                self.idImagemAtual = 0
                print(dbgmsg + "Limite minimo de imagens alcancado!")
            }
            
        }
        
    }
    
    
    
    
    
    
    //Mark: Funcoes de animacao para chamar e retirar o popover
    //funcao para chamar o popover
    func callPopover() {
        self.view.addSubview(self.configuracoesPopOver)
        self.configuracoesPopOver.center = self.view.center
        
        
        self.configuracoesPopOver.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.4, animations: {
            self.configuracoesPopOver.alpha = 1.0
            self.configuracoesPopOver.transform = CGAffineTransform.identity
        })
        
    }
    
    
    //funcao para remover o popover
    func removePopover() {
        UIView.animate(withDuration: 0.4, animations: {
            self.configuracoesPopOver.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            self.configuracoesPopOver.alpha = 0
        }, completion: {(sucess: Bool) in
            self.configuracoesPopOver.removeFromSuperview()
        })
    }

    
    
    
    
    
    
    
    
    //Mark: Funcoes de delegate do pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.configExecPickerData.count
    }

 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.configExecPickerData[row]
    }

    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let opcaoSelecionada = self.configExecPickerData[row]
        print(dbgmsg + "Configuracoes do exercicio 1. Selecionada opcao [\(opcaoSelecionada)]")
        
        
        /*Falta implementar para carregar todas as imagens*/
        carregarImagens(imagens: ImagemExercicioStore.getAllImagensExecs(incial: opcaoSelecionada))
        
    }
    
    
    
    //Mark: Funcao  para carregar as imagens de acordo com o nome dado
    func carregarImagens(imagens: [ImagemExercicio]) {
        
        self.estruturaDeAcertosErrosDuvidas = []
        self.duvidas = 0
        
        for imagem in imagens {
            
            self.estruturaDeAcertosErrosDuvidas?.append(acertoErroDuvidaStruct.init(imagemExec: imagem, estado: estadosDoExercicio1.duvida.rawValue))
            self.duvidas = duvidas + 1
 
        }
            
        
        self.ImageView.image = self.estruturaDeAcertosErrosDuvidas?.first?.imagemExec?.asset
        self.idImagemAtual = 0

         print(dbgmsg + "Estrutura de acertos,erros,duvidas com: \(self.estruturaDeAcertosErrosDuvidas?.count) elementos. Indice da imagem em: \(self.idImagemAtual)")
        
    }
    
    
    
    
    
    
    
    
    //Mark: Funcao para carregar imagens no vetor de imagens e mostra - las na tela
    func carregarTodasImagens(imagens: [ImagemExercicio],qtImagens: Int) {
      
        self.estruturaDeAcertosErrosDuvidas = []
        self.duvidas = 0

        var ultimoSelecionado: Int = 0
        var selecoes: Int = 0
        
        
        /*ALGORITMO ERRADO: FUNCIONA, MAS NAO ATINGE A LOGICA PRETENDIDA*/
        while selecoes < qtImagens {
            
            //pegando randomicamente uma imagem
            var imagemAleatoria = Int(arc4random_uniform(UInt32(imagens.count)))
            
            //verificando se a mesma imagem ja nao foi selecionada
            if self.estruturaDeAcertosErrosDuvidas?.count == 0 { //neste caso ainda nao existem imagens
                ultimoSelecionado = imagemAleatoria
            }else {
                if imagemAleatoria == ultimoSelecionado {
                    print(dbgmsg + "Foram selecionadas duas imagens iguais.")
                    
                    while true {
                        imagemAleatoria = Int(arc4random_uniform(UInt32(imagens.count)))
                        if imagemAleatoria != ultimoSelecionado {
                            ultimoSelecionado = imagemAleatoria
                            break
                        }
                    }
                }
            }
            
            self.estruturaDeAcertosErrosDuvidas?.append(acertoErroDuvidaStruct.init(imagemExec: imagens[imagemAleatoria], estado: estadosDoExercicio1.duvida.rawValue))

            self.duvidas = duvidas + 1
            

            selecoes = selecoes + 1
        }
        
        self.ImageView.image = self.estruturaDeAcertosErrosDuvidas?.first?.imagemExec?.asset
        self.idImagemAtual = 0
        
        
         print(dbgmsg + "Estrutura de acertos,erros,duvidas com: \(self.estruturaDeAcertosErrosDuvidas?.count) elementos. Indice da imagem em: \(self.idImagemAtual)")
        
        
        
        /*Antigo Codigo*/
        //percorrendo todas as imagens e adicionando cada uma no vetor
//        for imagem in imagens {
//            self.estruturaDeAcertosErrosDuvidas.append(acertoErroDuvidaStruct.init(imagemExec: imagem, estado: estadosDoExercicio1.duvida.rawValue))
//            self.duvidas = duvidas + 1
//        }
//        
//        print(dbgmsg + "Estrutura de acertos,erros,duvidas com: \(self.estruturaDeAcertosErrosDuvidas.count) elementos.")
//        
//        
//        self.ImageView.image = self.estruturaDeAcertosErrosDuvidas.first?.imagemExec?.asset
//        self.idImagemAtual = 0
        
    }
    
    
    
    
    
    
    
    //Mark: Funcao para carregar a tela de feedback via storyboard id
    func carregarTelaFeedaback() {
        
        //colocar alertas sobre algumas condicao "adversa" antes de chamar a tela de feedback
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FeedbackTipo1") as! FeedbackTipo1ViewController
        
        
        //carregando variaveis
        controller.acertos = self.acertos
        controller.erros = self.erros
        controller.duvidas = self.duvidas
    
        
        //chamando controladora
        self.present(controller, animated: true, completion: nil)
    }
    
    
    //Mark: funcao para verificar se todas as imagens ja foram tidas como corretas ou erradas
    func verificarSeTodasImagensForamRespondidas() -> Bool{
        
        if self.duvidas == 0 {
            return true
        }else {
            return false
        }
    }
    
    
    
    //Mark: Criar alerta para informar que todas as imagens foram respondidas 
    func alertarConclusaoExercicio() {
        

        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Ok") {
            print(self.dbgmsg + "Exercicio concluido. Indo para a tela de feedback.")
            //chamar a tela de feedback aqui
            self.carregarTelaFeedaback()
        }
        
        alert.showSuccess("Exercício Concluído", subTitle: "Você completou este exercício. Veja seus resultados!")
    }
    
    
    
    
    //Mark: Criar alerta para informar que o exercicio esta em curso caso o usuario queira sair
    func alertarExercicioEmCurso(irParaFeedback: Bool) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Sair") {
            
            //escolhe se deseja carregar a tela de feedback ou sair para a tela anterior
            if irParaFeedback {
                print(self.dbgmsg + "Saindo do exercicio.Indo para o feedback")
                self.carregarTelaFeedaback()
            }else {
                print(self.dbgmsg + "Saindo do exercicio.Indo para a selecao de jogos")
                self.dismiss(animated: true) {
                    print(self.dbgmsg + "Voltando para tela anterior")
                }
            }
        }
        
        
        /*NECESSITA AJEITAR*/
        alert.showWarning("Sair do Exercício?", subTitle: "Você deseja realmente sair deste exercício?", closeButtonTitle: "Cancelar", timeout: nil, colorStyle: 0xFED035, colorTextButton: 0x262626, animationStyle: .topToBottom)
       
    }
    
    
    
    
    //Mark: Funcao para passar as imagens de forma automatica
    func carregarProximaImagem() {
        print(dbgmsg + "Index anterior: \(self.idImagemAtual)")
        self.idImagemAtual = self.idImagemAtual! + 1
        if idImagemAtual! < (self.estruturaDeAcertosErrosDuvidas?.count)!{
             self.ImageView.image = self.estruturaDeAcertosErrosDuvidas?[idImagemAtual!].imagemExec?.asset
        }
        
    }
    
    
    
    
    
    
    
}
