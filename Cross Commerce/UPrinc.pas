unit UPrinc;

interface                 

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, Buttons, ExtCtrls, ComCtrls;

type
  TFPrinc = class(TForm)
    IdHTTP1: TIdHTTP;
    MemoDados: TMemo;
    MemoNumeros: TMemo;
    MemoOrdenados: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    laPag: TLabel;
    Timer1: TTimer;
    btnExtrair: TBitBtn;
    ProgressBar1: TProgressBar;
    Label4: TLabel;
    btnSair: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnExtrairClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Separa_numeros;
    procedure Ordenar;
    procedure btnSairClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPrinc: TFPrinc;

implementation

{$R *.dfm}


 var
  Vetor: array of extended;
  x_numpagina : integer;
  x_retorno : tstringlist;
  x_pagina : string;

procedure TFPrinc.FormCreate(Sender: TObject);
begin
   x_retorno := TStringList.Create;
end;

procedure TFPrinc.btnExtrairClick(Sender: TObject);
begin
   btnExtrair.Enabled := false;
   btnSair.Setfocus;

   MemoDados.clear;
   memoNumeros.clear;
   memoOrdenados.clear;

   ProgressBar1.Visible := true;
   label4.Caption := 'Aguarde, Processando ...';
   label4.Visible := true;

   x_numpagina := 1;
   timer1.Enabled := true;

end;



procedure TFPrinc.Timer1Timer(Sender: TObject);
begin

   timer1. enabled := false;

   try
    x_pagina := 'http://challenge.dienekes.com.br/api/numbers?page=' + inttostr(x_numpagina);

    laPag.Caption := inttostr(x_numpagina);
    x_retorno.Text := IdHTTP1.Get(x_pagina);

    if ProgressBar1.Position = 100 then
      ProgressBar1.Position := 0;
    ProgressBar1.Position := ProgressBar1.Position + 10;

    MemoDados.lines := x_retorno;

    Separa_numeros;

   except
    timer1. enabled := true;
   end;


end;

procedure TFPrinc.Separa_numeros;
var
 aux, aux2, auxfim, numstr : string;
 pos : integer;
begin

   if length(x_retorno[0]) < 14 then
       begin
         timer1.enabled := true;
       end
      else
       begin
        auxfim := copy(x_retorno[0],1,14);
        if (auxfim <> '{"numbers":[]}') then
           begin
            aux := copy(x_retorno[0],1,12);
            aux2 := copy(x_retorno[0], length(x_retorno[0])-1,2);
            if (aux = '{"numbers":[') and (aux2 = ']}') then      // teste do inicio e fim esperados, da string recebida
               begin
                pos := 13;
                aux := copy(x_retorno[0],pos,1);

                while (aux <> '}') and (pos < length(x_retorno[0])) do
                 begin

                  numstr := '';
                  while (aux <> ',') and (aux <> ']') do
                   begin
                    if aux = '.' then    // nos números (string) recebidos, troca-se o ponto por vírgula para não erro ao transformá-lo em tipo numérico
                       aux :=',';
                    numstr := numstr + aux;
                    pos := pos + 1;
                    aux := copy(x_retorno[0],pos,1);
                   end;

                  memoNumeros.Lines.Add(numstr);

                  pos := pos + 1;
                  aux := copy(x_retorno[0],pos,1);

                 end;
               end;

            x_numpagina := x_numpagina + 1;
            timer1.Enabled := true;
           end
          else
           begin
            memoDados.Lines.Add(' ');
            memoDados.Lines.Add('Fim da leitura');
            memoDados.Lines.Add(' ');
            memoDAdos.Lines.Add('Quantidade de números lidos: ' + inttostr(memoNumeros.lines.count));
            ProgressBar1.Visible := false;

            showmessage('Vamos partir para a ordenação, deve demorar um pouco');
            ordenar;

            memoDAdos.Lines.Add('Quantidade de números ordenados: ' + inttostr(memoOrdenados.lines.count));
            label4.Caption := 'Processamento Finalizado!';

           end;
       end;
end;

procedure TFPrinc.Ordenar;
 var
  num : extended;
  indice, linha, preenchido, ver, empurra :integer;
  chave :string;
begin

   SetLength(Vetor, memoNumeros.lines.count);  // definindo o tamanho do vetor que conterá os números ordenados

   vetor[0] := strtofloat(memoNumeros.lines.Strings[0]);

   indice := 1;       // controla os números recebidos
   preenchido := 0;     // controla a última posiçãodo preenchida do vetor ordenado

   while indice <= memoNumeros.lines.count - 1 do
    begin
     num := strtofloat(memoNumeros.lines.Strings[indice]);

     if (vetor[preenchido] <= num) then     // teste - é possível colocar o número recebido  na última posição do vetor ordenado
        begin
         preenchido := preenchido + 1 ;
         vetor[preenchido] := num;
        end
       else
        begin
         ver := 0;
         while (vetor[ver] < num ) do      // procurar pela posição no vetor, onde o número recebido se encaixa.
          begin
            ver := ver + 1
          end;

         empurra := preenchido;       //empurrar os números do vetor para liberar a posição onde o número recebido deverá ser encaixado
         while empurra >= ver do
          begin
           vetor[empurra + 1] := vetor[empurra];
           empurra := empurra - 1;
          end;
         vetor[ver] :=  num;
         preenchido := preenchido + 1 ;
        end;

     indice := indice + 1;      //passar para o próximo recebido
    end;

   MemoOrdenados.Clear;
   for indice := 0 to MemoNumeros.Lines.Count -1 do
       MemoOrdenados.Lines.Add(floattostr(vetor[indice]));

   btnExtrair.Enabled := true;

end;


procedure TFPrinc.btnSairClick(Sender: TObject);
begin
   if MessageDlg('Deseja realmente sair do sistema?',
      mtInformation, [mbYes, mbNo], 0) = mrYes then
      close;
end;

procedure TFPrinc.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FreeAndNil(x_retorno);
   Application.terminate;
end;

end.
