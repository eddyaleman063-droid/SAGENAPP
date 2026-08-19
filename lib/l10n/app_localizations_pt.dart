// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutSage => 'Sobre o Sage';

  @override
  String get aboutSection => 'Sobre';

  @override
  String get achievementConqueror => 'Conquistador';

  @override
  String get achievementConquerorDesc => 'Conclua sua primeira etapa';

  @override
  String get achievementConstant => 'Constante';

  @override
  String get achievementConstantDesc => 'Sequência de 3 dias';

  @override
  String get achievementCurious => 'Curioso';

  @override
  String get achievementCuriousDesc => 'Converse com o Sage 10 vezes';

  @override
  String get achievementCyberGuardian => 'Ciber Guardião';

  @override
  String get achievementCyberGuardianDesc => 'Conclua 50 lições';

  @override
  String get achievementDigitalMaster => 'Mestre Digital';

  @override
  String get achievementDigitalMasterDesc => 'Conclua todas as etapas';

  @override
  String get achievementDigitalStudent => 'Estudante Digital';

  @override
  String get achievementDigitalStudentDesc => 'Conclua 10 lições';

  @override
  String get achievementDigitalWeek => 'Semana Digital';

  @override
  String get achievementDigitalWeekDesc => 'Sequência de 7 dias';

  @override
  String get achievementFirstShield => 'Primeiro Escudo';

  @override
  String get achievementFirstShieldDesc => 'Conclua sua primeira lição';

  @override
  String get achievementGuardian => 'Guardião';

  @override
  String get achievementGuardianDesc => 'Conclua 25 lições';

  @override
  String get achievementLearner => 'Aprendiz';

  @override
  String get achievementLearnerDesc => 'Conclua 5 lições';

  @override
  String get achievementLegendaryStreak => 'Sequência Lendária';

  @override
  String get achievementLegendaryStreakDesc => 'Sequência de 30 dias';

  @override
  String get achievementLocked => '???';

  @override
  String get achievementPerfect => 'Perfeito';

  @override
  String get achievementPerfectDesc => 'Conclua uma lição sem erros';

  @override
  String get acquired => 'Adquirido';

  @override
  String get adminCreditDonationA11y => 'Creditar Doações';

  @override
  String get adminCreditDonationButton => 'Creditar Doações';

  @override
  String adminCreditDonationSuccess(Object gems, Object userId) {
    return '$gems doações creditadas para $userId';
  }

  @override
  String get adminCreditDonationTitle => 'Admin — Creditar Doações';

  @override
  String get adminCreditError =>
      'Erro ao creditar. Verifique se seu usuário está na coleção \"admins\" do Firestore.';

  @override
  String adminCreditSuccessNotification(Object gems, Object userId) {
    return '$gems doações creditadas para $userId';
  }

  @override
  String get adminDonations => 'Doações';

  @override
  String get adminFieldAmount => 'Valor';

  @override
  String get adminFieldDonationAmount => 'Valor da doação';

  @override
  String get adminFieldUserId => 'User ID';

  @override
  String get adminInvalidInput => 'Insira um User ID válido e valor';

  @override
  String get adminMercadoPago => 'Mercado Pago';

  @override
  String get adminPaymentMethod => 'Método de pagamento';

  @override
  String get adminTitle => 'Admin — Doações de Crédito';

  @override
  String get adminUserId => 'ID do Usuário';

  @override
  String get adminVerifyingPermissions =>
      'Verificando permissões de administrador…';

  @override
  String get adminWhatsapp => 'WhatsApp / Yape / Plin';

  @override
  String get analyzeFile => 'Analisar arquivo';

  @override
  String get analyzeLink => 'Analisar link';

  @override
  String get analyzing => 'Analisando...';

  @override
  String get appName => 'SAGEN';

  @override
  String get appSlogan => 'Seu escudo digital';

  @override
  String get authAge => 'Idade';

  @override
  String get authBack => 'Voltar';

  @override
  String get authCanceled => 'Login cancelado';

  @override
  String get authConfirmPassword => 'Confirmar senha';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authCreateAccountError => 'Erro ao criar conta';

  @override
  String get authCredentialExpired => 'Sessão expirada. Faça login novamente.';

  @override
  String get authDefault => 'Erro de autenticação';

  @override
  String get authDeleteAccountFailed =>
      'Não foi possível excluir a conta. Tente novamente.';

  @override
  String get authEmailError => 'Digite seu e-mail';

  @override
  String get authEmailInUse => 'Já existe uma conta com este e-mail';

  @override
  String get authEmailInvalid => 'E-mail inválido';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authEmailVerificationSent =>
      'Verifique seu e-mail para confirmar sua conta';

  @override
  String get authEnterEmailError => 'Digite seu e-mail';

  @override
  String get authFacebookButton => 'Continuar com Facebook';

  @override
  String get authFacebookError => 'Erro ao entrar com Facebook';

  @override
  String get authFirebaseUnavailable => 'Firebase não está disponível';

  @override
  String get authForgotPasswordButton => 'REDEFINIR SENHA';

  @override
  String get authForgotPasswordDesc =>
      'Enviaremos um link para redefinir sua senha.';

  @override
  String get authForgotPasswordTitle => 'Redefinir senha';

  @override
  String get authFullName => 'Nome completo';

  @override
  String get authGoogleButton => 'Continuar com Google';

  @override
  String get authGoogleError => 'Erro ao entrar com Google';

  @override
  String get authHaveAccount => 'Já tem uma conta? ';

  @override
  String get authInvalidCredential => 'E-mail ou senha incorretos';

  @override
  String get authInvalidEmail => 'Formato de e-mail inválido';

  @override
  String get authLoginButton => 'ENTRAR';

  @override
  String get authLoginError => 'Erro ao fazer login';

  @override
  String get authLoginLink => 'Entrar';

  @override
  String get authLoginTitle => 'Insira seus dados';

  @override
  String get authNameError => 'Digite seu nome';

  @override
  String get authNetworkError => 'Sem conexão com a internet';

  @override
  String get authNoAccount => 'Não tem uma conta? ';

  @override
  String get authNotAuthenticated => 'Nenhum usuário autenticado';

  @override
  String get authNotFound => 'Nenhuma conta encontrada com este e-mail';

  @override
  String get authNotFoundCancel => 'Cancelar';

  @override
  String get authNotFoundCreate => 'Criar conta';

  @override
  String authNotFoundMessage(Object email) {
    return 'Não existe uma conta registrada com $email. Deseja criar uma nova conta e começar a aprender?';
  }

  @override
  String get authNotFoundTitle => 'Conta não encontrada';

  @override
  String get authNotVerified =>
      'E-mail ainda não verificado. Verifique sua caixa de entrada.';

  @override
  String get authNullToken => 'Não foi possível obter o token do Facebook';

  @override
  String get authNullUser => 'Não foi possível obter o usuário';

  @override
  String get authOrRegisterWith => 'ou cadastre-se com';

  @override
  String get authPasswordError => 'Digite sua senha';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authPasswordMinError =>
      'A senha deve ter 8+ caracteres com maiúscula, minúscula e um número';

  @override
  String get authPasswordMinHint => 'Senha (8+ caracteres, A-Z, a-z, 0-9)';

  @override
  String get authPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get authPrivacy => 'Suas informações estão protegidas.';

  @override
  String get authRateLimited => 'Muitas tentativas. Aguarde alguns segundos.';

  @override
  String get authReauthError =>
      'Não foi possível verificar as credenciais. Tente novamente.';

  @override
  String get authReauthRequiredForDelete =>
      'Digite sua senha para excluir sua conta.';

  @override
  String get authRecoveryEmailSentDesc =>
      'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.';

  @override
  String get authRecoveryEmailSentMessage => 'E-mail de recuperação enviado';

  @override
  String get authRecoveryEmailSentTitle => 'E-mail enviado';

  @override
  String get authRecoveryError =>
      'Não foi possível enviar e-mail de recuperação';

  @override
  String get authRegisterFacebookError => 'Erro ao cadastrar com Facebook';

  @override
  String get authRegisterGoogleError => 'Erro ao cadastrar com Google';

  @override
  String get authRegisterTitle => 'Crie sua conta';

  @override
  String get authResendEmailError =>
      'Não foi possível reenviar e-mail de verificação';

  @override
  String get authSendEmailError => 'Erro ao enviar e-mail';

  @override
  String get authSendLink => 'Enviar link';

  @override
  String get authSubtitle =>
      'Aprenda, proteja-se e navegue na internet com mais segurança.';

  @override
  String get authTitle => 'Sua proteção digital começa aqui';

  @override
  String get authTokenExpired => 'Sessão expirada. Faça login novamente.';

  @override
  String get authTooManyRequests => 'Muitas tentativas. Aguarde.';

  @override
  String get authUnknown => 'Ocorreu um erro inesperado';

  @override
  String get authVerifyError => 'Não foi possível verificar. Tente novamente.';

  @override
  String get authWeakPassword => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get authWrongPassword => 'Senha incorreta';

  @override
  String get back => 'Voltar';

  @override
  String get backButton => 'Voltar';

  @override
  String get biometricPrompt => 'Desbloqueie o SAGEN para continuar';

  @override
  String get biometricReason => 'Desbloqueie o SAGEN para continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get careerCertifications => 'Certificações';

  @override
  String get careerDescription =>
      'Obtenha certificações e desenvolva habilidades que te tornam valioso na economia digital.';

  @override
  String get careerOpp1 => 'Consultor de Segurança Digital';

  @override
  String get careerOpp1Desc => 'Ajude empresas a proteger seus dados';

  @override
  String get careerOpp2 => 'Treinador de Conscientização em Cibersegurança';

  @override
  String get careerOpp2Desc => 'Ensine outros a ficarem seguros online';

  @override
  String get careerOpp3 => 'Auditor de Segurança Freelancer';

  @override
  String get careerOpp3Desc => 'Ofereça auditorias de segurança para clientes';

  @override
  String get careerOpportunities => 'Oportunidades Econômicas';

  @override
  String get careerSkill1 => 'Segurança de Senhas';

  @override
  String get careerSkill2 => 'Detecção de Phishing';

  @override
  String get careerSkill3 => 'Proteção de Privacidade';

  @override
  String get careerSkill4 => 'Segurança de Redes';

  @override
  String get careerSkill5 => 'Resposta a Incidentes';

  @override
  String get careerSkills => 'Habilidades que você está desenvolvendo';

  @override
  String get careerSubtitle => 'Seu caminho profissional em cibersegurança';

  @override
  String get careerTitle => 'Carreira e Certificações';

  @override
  String get challengeComplete => 'Complete a frase';

  @override
  String get challengeCreatePassword => 'Criar senha';

  @override
  String get challengeDetectRisk => 'Detectar risco';

  @override
  String get challengeMiniCase => 'Caso real';

  @override
  String get challengeMultiple => 'Múltipla escolha';

  @override
  String get challengeSafe => 'Seguro';

  @override
  String get challengeSuspicious => 'Suspeito';

  @override
  String get challengeTrueFalse => 'Verdadeiro / Falso';

  @override
  String get challengeWhatWouldYouDo => 'O que você faria?';

  @override
  String challenge_analyze_link_desc(Object count) {
    return 'Analise $count link(s)';
  }

  @override
  String get challenge_analyze_link_title => 'Analisar Links';

  @override
  String challenge_answer_questions_desc(Object count) {
    return 'Responda $count pergunta(s)';
  }

  @override
  String get challenge_answer_questions_title => 'Responder Perguntas';

  @override
  String challenge_check_in_desc(Object count) {
    return 'Faça check-in $count vez(es)';
  }

  @override
  String get challenge_check_in_title => 'Check-in Diário';

  @override
  String challenge_complete_lesson_desc(Object count) {
    return 'Conclua $count lição(ões)';
  }

  @override
  String get challenge_complete_lesson_title => 'Concluir Lições';

  @override
  String challenge_complete_session_desc(Object count) {
    return 'Conclua $count sessão(ões)';
  }

  @override
  String get challenge_complete_session_title => 'Sessões de Aprendizado';

  @override
  String get challenge_complete_stage_desc => 'Conclua 1 etapa';

  @override
  String get challenge_complete_stage_title => 'Concluir Etapa';

  @override
  String challenge_correct_streak_desc(Object count) {
    return 'Acerto $count respostas corretas seguidas';
  }

  @override
  String get challenge_correct_streak_title => 'Sequência Correta';

  @override
  String challenge_detect_phishing_desc(Object count) {
    return 'Detecte $count tentativa(s) de phishing';
  }

  @override
  String get challenge_detect_phishing_title => 'Detectar Phishing';

  @override
  String challenge_earn_xp_desc(Object xp) {
    return 'Ganhe $xp XP';
  }

  @override
  String get challenge_earn_xp_title => 'Ganhar XP';

  @override
  String challenge_learn_minutes_desc(Object count) {
    return 'Aprenda por $count minutos';
  }

  @override
  String get challenge_learn_minutes_title => 'Tempo de Aprendizado';

  @override
  String challenge_learn_topic_desc(Object count) {
    return 'Aprenda $count tópico(s)';
  }

  @override
  String get challenge_learn_topic_title => 'Aprender um Tópico';

  @override
  String get challenge_perfect_lesson_desc => 'Conclua uma lição sem erros';

  @override
  String get challenge_perfect_lesson_title => 'Lição Perfeita';

  @override
  String challenge_privacy_check_desc(Object count) {
    return 'Revise configurações de privacidade $count vez(es)';
  }

  @override
  String get challenge_privacy_check_title => 'Verificação de Privacidade';

  @override
  String challenge_quiz_night_desc(Object count) {
    return 'Conclua $count mini quiz(es)';
  }

  @override
  String get challenge_quiz_night_title => 'Mini Quiz';

  @override
  String challenge_review_tips_desc(Object count) {
    return 'Revise $count dica(s) de segurança';
  }

  @override
  String get challenge_review_tips_title => 'Revisar Dicas';

  @override
  String challenge_security_audit_desc(Object count) {
    return 'Conclua $count auditoria(s) de segurança';
  }

  @override
  String get challenge_security_audit_title => 'Auditoria de Segurança';

  @override
  String challenge_share_knowledge_desc(Object count) {
    return 'Compartilhe $count dica(s)';
  }

  @override
  String get challenge_share_knowledge_title => 'Compartilhar Conhecimento';

  @override
  String challenge_social_awareness_desc(Object count) {
    return 'Conclua $count desafio(s) de consciência social';
  }

  @override
  String get challenge_social_awareness_title => 'Consciência Social';

  @override
  String challenge_streak_milestone_desc(Object count) {
    return 'Mantenha uma sequência de $count dias';
  }

  @override
  String get challenge_streak_milestone_title => 'Marco de Sequência';

  @override
  String get gemMilestoneTitle => 'Coleccionador de Gemas!';

  @override
  String gemMilestoneDesc(Object count) {
    return 'Você ganhou $count gemas no total! Continue coleccionando!';
  }

  @override
  String challenge_talk_sage_desc(Object count) {
    return 'Converse com Sage $count vez(es)';
  }

  @override
  String get challenge_talk_sage_title => 'Conversar com Sage';

  @override
  String challenge_test_password_desc(Object count) {
    return 'Teste $count senha(s)';
  }

  @override
  String get challenge_test_password_title => 'Testar Senhas';

  @override
  String get challenge_use_dark_mode_desc => 'Usar modo escuro';

  @override
  String get challenge_use_dark_mode_title => 'Modo Escuro';

  @override
  String get changelogV4 => 'Fundação';

  @override
  String get changelogV4_1 => '8 etapas de aprendizado com 1.099 lições';

  @override
  String get changelogV4_2 => 'Sequência e desafios diários';

  @override
  String get changelogV4_3 => 'Sistema de conquistas';

  @override
  String get changelogV5 => 'IA e Personalização';

  @override
  String get changelogV5Old => 'Sistema de Baús e Gacha';

  @override
  String get changelogV5Old_1 =>
      'Sistema de evolução de baús (Bronze → Lendário)';

  @override
  String get changelogV5Old_2 => 'Botões 3D interativos';

  @override
  String get changelogV5Old_3 => 'Redesenho da UI com Glassmorphism';

  @override
  String get changelogV5_1 => 'Chat SAGE com IA para ajuda personalizada';

  @override
  String get changelogV5_2 => 'Emoções dinâmicas do mascote';

  @override
  String get changelogV5_3 => '17.157 perguntas de cibersegurança';

  @override
  String get changelogV5_4 => 'Sociedade VIP para sequências de 30+ dias';

  @override
  String get chatAskSage => 'Pergunte ao Sage';

  @override
  String get chatAskSageDesc =>
      'Faça qualquer pergunta sobre cibersegurança ou escolha uma sugestão rápida.';

  @override
  String get chatBlocked => 'Chat bloqueado';

  @override
  String get chatCancel => 'Cancelar';

  @override
  String get chatClear => 'Limpar';

  @override
  String get chatClearAction => 'Limpar';

  @override
  String get chatClearMessage =>
      'Tem certeza de que deseja limpar esta conversa? Esta ação não pode ser desfeita.';

  @override
  String get chatClearTitle => 'Limpar conversa';

  @override
  String get chatEmptyTitle => 'Inicie uma conversa';

  @override
  String get chatFallback => 'Não consegui responder agora. Tente novamente.';

  @override
  String get chatFallbackSubtitle =>
      'Escreva qualquer dúvida sobre cibersegurança ou escolha uma sugestão rápida.';

  @override
  String get chatFallbackTitle => 'Pergunte ao Sage';

  @override
  String get chatGuideDesc => 'Seu guia de cibersegurança';

  @override
  String get chatGuideSubtitle => 'Seu guia de cibersegurança';

  @override
  String get chatHint => 'Pergunte ao Sage...';

  @override
  String get chatInputHint => 'Pergunte ao Sage...';

  @override
  String get chatNewConversation => 'Nova conversa';

  @override
  String get chatSageTutor => 'Tutor Sage';

  @override
  String get chatSageTutorLabel => 'Tutor Sage';

  @override
  String get checkInDesc => 'Check-in diário para manter sua sequência ativa';

  @override
  String get checkInTitle => 'Check-in';

  @override
  String get chestCollect => 'Coletar';

  @override
  String chestEvolvedTo(Object type) {
    return 'Evoluiu para $type';
  }

  @override
  String get chestNoChange => 'Nenhuma mudança';

  @override
  String chestOpenedTitle(Object type) {
    return 'Baú $type!';
  }

  @override
  String get chestPityProgress => 'Lendário em';

  @override
  String get chestReminder => 'Lembretes de Baú';

  @override
  String get chestReminderSubtitle =>
      'Receba lembretes para abrir o baú diário';

  @override
  String get chestRewardBronze => 'Bronze!';

  @override
  String get chestRewardDefault => 'Recompensa';

  @override
  String get chestRewardDialog => 'Diálogo de recompensa do baú';

  @override
  String get chestRewardGold => 'Ouro!';

  @override
  String get chestRewardLegendary => 'Lendário!';

  @override
  String get chestRewardSilver => 'Prata!';

  @override
  String get chestTapToOpen => 'Toque para abrir';

  @override
  String get chestTapToUpgrade => 'Toque para evoluir';

  @override
  String chestTitle(Object type) {
    return 'Baú $type';
  }

  @override
  String chestTreasure(Object type) {
    return 'Cofre do tesouro $type';
  }

  @override
  String chestTreasureLabel(Object type) {
    return 'Tesouro $type';
  }

  @override
  String get chestTypeBronze => 'Bronze';

  @override
  String get chestTypeGold => 'Ouro';

  @override
  String get chestTypeLegendary => 'Lendário';

  @override
  String get chestTypeSilver => 'Prata';

  @override
  String get chestXpBoost => 'x2 XP';

  @override
  String get closeButton => 'Fechar';

  @override
  String get cloudDataDeleted => 'Dados na nuvem excluídos';

  @override
  String get cloudSync => 'Sincronização na Nuvem';

  @override
  String get commit1Month => '1 mês';

  @override
  String get commit1Week => '1 semana';

  @override
  String get commit2Weeks => '2 semanas';

  @override
  String get commitButton => 'COMPROMETER-SE COM MINHA META';

  @override
  String get commitChooseGoal => 'Escolha sua meta';

  @override
  String get commitChooseGoalDesc =>
      'Selecione por quantos dias você seguirá seu plano de aprendizado.';

  @override
  String commitDays(Object days) {
    return '$days dias';
  }

  @override
  String commitGoalLabel(Object days) {
    return 'Sua meta: $days dias';
  }

  @override
  String get commitSelected => 'SELECIONADO';

  @override
  String commitYourGoal(Object days) {
    return 'Sua meta: $days dias';
  }

  @override
  String get completePrevious => 'Complete a etapa anterior';

  @override
  String get connectionErrorRetry => 'Erro de conexão. Tente novamente.';

  @override
  String continueLesson(Object title) {
    return 'Continuar lição: $title';
  }

  @override
  String get continueText => 'Continuar';

  @override
  String get correct => 'Correto';

  @override
  String get correctAnswer => 'Resposta correta';

  @override
  String correctAnswers(Object correct, Object total) {
    return '$correct de $total corretas';
  }

  @override
  String get currencySymbol => 'R\$';

  @override
  String cyberQuizProgress(Object current, Object total) {
    return 'Pergunta $current de $total';
  }

  @override
  String get dailyGoalIntense => 'Intenso';

  @override
  String dailyGoalMinutesPerDay(Object minutes) {
    return '$minutes min/dia';
  }

  @override
  String get dailyGoalNormal => 'Normal';

  @override
  String get dailyGoalQuestion => 'Qual é a sua meta diária de aprendizado?';

  @override
  String get dailyGoalRelaxed => 'Relaxado';

  @override
  String get dailyGoalSerious => 'Séria';

  @override
  String get dailyMissions => 'Missões diárias';

  @override
  String get dailyMissionsAllCompleted => 'Todos os desafios concluídos hoje!';

  @override
  String get dailyMissionsDesc =>
      'Conclua suas missões para ganhar recompensas';

  @override
  String get darkModeEnd => 'Finalizar modo escuro';

  @override
  String darkModeScheduleInfo(Object end, Object start) {
    return 'O modo escuro estará ativo das $start:00 às $end:00';
  }

  @override
  String get darkModeStart => 'Iniciar modo escuro';

  @override
  String get dayAbbrFri => 'Sex';

  @override
  String get dayAbbrMon => 'Seg';

  @override
  String get dayAbbrSat => 'Sáb';

  @override
  String get dayAbbrSun => 'Dom';

  @override
  String get dayAbbrThu => 'Qui';

  @override
  String get dayAbbrTue => 'Ter';

  @override
  String get dayAbbrWed => 'Qua';

  @override
  String get dayShortFri => 'S';

  @override
  String get dayShortMon => 'S';

  @override
  String weekDayCompleted(Object day) {
    return '$day, concluído';
  }

  @override
  String weekDayToday(Object day) {
    return 'Hoje, $day';
  }

  @override
  String get dayShortSat => 'S';

  @override
  String get dayShortSun => 'D';

  @override
  String get dayShortThu => 'Q';

  @override
  String get dayShortTue => 'T';

  @override
  String get dayShortWed => 'Q';

  @override
  String get streakStatusCompleted => 'concluído';

  @override
  String get streakStatusToday => 'hoje';

  @override
  String get streakStatusPending => 'pendente';

  @override
  String get daysLabel => 'dias';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteAccountConfirm => 'Excluir minha conta';

  @override
  String get deleteAccountDesc =>
      'Isso excluirá permanentemente todos os seus dados. Esta ação é irreversível.';

  @override
  String get deleteAccountReauthRequired =>
      'Autenticação recente necessária para excluir a conta';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAction => 'Excluir';

  @override
  String get deleteCloudData => 'Excluir Dados na Nuvem';

  @override
  String get deleteCloudDesc =>
      'Tem certeza? Isso excluirá permanentemente seu progresso salvo na nuvem. Os dados locais não serão afetados.';

  @override
  String get deleteCloudTitle => 'Excluir Dados na Nuvem';

  @override
  String get deleteHistory => 'Excluir Histórico de Análises';

  @override
  String get deleteHistoryDesc =>
      'Todas as análises de links salvas serão excluídas. Esta ação é irreversível.';

  @override
  String get deleteHistoryTitle => 'Excluir Histórico';

  @override
  String get demoModeLabel => 'MODO DEMO';

  @override
  String get demoStudentName => 'Estudante demo';

  @override
  String get developedWith => 'Desenvolvido com Flutter';

  @override
  String get donateToSupport => 'Doar para apoiar';

  @override
  String get donationBasic => 'Supporter';

  @override
  String get donationBasicDesc => 'Ajude-nos a manter o SAGEN gratuito';

  @override
  String get donationLabel => 'Doação';

  @override
  String get donationPopular => 'Super Supporter';

  @override
  String get donationPopularDesc => 'Badge exclusivo + agradecimento especial';

  @override
  String get donationPremium => 'Campeão';

  @override
  String get donationPremiumDesc =>
      'Todos os benefícios + seu nome nos créditos';

  @override
  String get donationValueLabel => 'Valor';

  @override
  String dot(Object number) {
    return 'Ponto $number';
  }

  @override
  String get ecoCo2Saved => 'Emissões de CO₂ evitadas';

  @override
  String get ecoComparison =>
      'SAGEN usa 99% menos recursos que a educação tradicional';

  @override
  String get ecoDescription =>
      'Cada lição concluída economiza papel, água e reduz emissões de carbono em comparação com a educação tradicional.';

  @override
  String get ecoDigital => '📱 Digital: apenas seu celular';

  @override
  String get ecoDigitalLearning => 'Aprendizado 100% Digital';

  @override
  String get ecoDigitalLearningDesc =>
      'Sem papel, sem impressão, sem transporte necessário';

  @override
  String get ecoHowItWorks => 'Digital vs Tradicional';

  @override
  String get ecoLiters => 'litros';

  @override
  String get ecoPages => 'páginas';

  @override
  String get ecoPaperSaved => 'Papel economizado';

  @override
  String get ecoSubtitle => 'Aprender cuidando do planeta';

  @override
  String get ecoTitle => 'Impacto Ecológico';

  @override
  String get ecoTraditional => '📚 Tradicional: papel, tinta, transporte';

  @override
  String get ecoTrees => 'árvores';

  @override
  String get ecoTreesEquivalent => 'Equivalente em árvores';

  @override
  String get ecoWaterSaved => 'Água economizada';

  @override
  String get ecoYourImpact => 'Seu impacto ambiental';

  @override
  String get emotionPhrase1 => 'Você detecta riscos mais rápido agora.';

  @override
  String get emotionPhrase2 => 'Seu hábito digital está melhorando.';

  @override
  String get emotionPhrase3 => 'Cada dia você entende melhor como se proteger.';

  @override
  String get emotionPhrase4 =>
      'Você está construindo um instinto de segurança.';

  @override
  String get emotionPhrase5 => 'Seu julgamento digital está se afiando.';

  @override
  String get emotionPhrase6 =>
      'Você está aprendendo a ver o que outros não veem.';

  @override
  String get emotionPhrase7 =>
      'Seu mundo digital está mais seguro graças a você.';

  @override
  String get emotionPhraseStart => 'Sua jornada digital começa hoje.';

  @override
  String get emotionalPhrase1 => 'Você detecta riscos mais rápido agora.';

  @override
  String get emotionalPhrase2 => 'Seu hábito digital está melhorando.';

  @override
  String get emotionalPhrase3 =>
      'Cada dia você entende melhor como se proteger.';

  @override
  String get emotionalPhrase4 =>
      'Você está construindo um instinto de segurança.';

  @override
  String get emotionalPhrase5 => 'Seu julgamento digital está se afiando.';

  @override
  String get emotionalPhrase6 =>
      'Você está aprendendo a ver o que outros não veem.';

  @override
  String get emotionalPhrase7 =>
      'Seu mundo digital é mais seguro por sua causa.';

  @override
  String get emotionalPhraseStart => 'Sua jornada digital começa hoje.';

  @override
  String get emptyChatSubtitle => 'Sage está pronto para ajudá-lo';

  @override
  String get emptyProfile => 'Sem dados de perfil';

  @override
  String get emptyStore => 'A loja está vazia';

  @override
  String get emptyUpdates => 'Nenhuma atualização disponível';

  @override
  String get english => 'Inglês';

  @override
  String get errorContentLoadFailed =>
      'Não foi possível carregar o conteúdo. Verifique sua conexão e tente novamente.';

  @override
  String get errorFeedback => 'Falha ao salvar feedback. Tente novamente.';

  @override
  String get errorGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get errorIntegrityCheck =>
      'Um problema de integridade foi detectado. Seu progresso foi mantido, mas verifique se está correto.';

  @override
  String get errorLoadContent =>
      'Não foi possível carregar o conteúdo. Verifique sua conexão e tente novamente.';

  @override
  String get errorLoadProgress =>
      'Não foi possível carregar seu progresso. Verifique sua conexão e tente novamente.';

  @override
  String get errorLoadQuestions =>
      'Falha ao carregar perguntas. Tente novamente.';

  @override
  String get errorNetwork => 'Sem conexão com a internet. Verifique sua rede.';

  @override
  String get errorPayment => 'Falha ao registrar pagamento. Tente novamente.';

  @override
  String get errorProgressLoadFailed =>
      'Não foi possível carregar seu progresso. Verifique sua conexão e tente novamente.';

  @override
  String get errorProgressReloadFailed =>
      'Não foi possível recarregar seu progresso. Tente novamente.';

  @override
  String get errorReloadProgress =>
      'Não foi possível recarregar seu progresso. Tente novamente.';

  @override
  String get errorRestartApp => 'Reiniciar aplicativo';

  @override
  String get errorRetry => 'Tentar novamente';

  @override
  String get errorShare => 'Falha ao compartilhar. Tente novamente.';

  @override
  String get errorSomethingWrong => 'Algo deu errado';

  @override
  String get errorStreak => 'Falha ao salvar progresso da sequência.';

  @override
  String get errorUnexpected =>
      'Ocorreu um erro inesperado. Você pode tentar novamente.';

  @override
  String get exitText => 'Sair';

  @override
  String get experience => 'Experiência';

  @override
  String get exportData => 'Exportar meus dados';

  @override
  String get exportDataCopied => 'Dados copiados para a área de transferência!';

  @override
  String get exportDataCopy => 'Copiar para área de transferência';

  @override
  String get exportDataDesc => 'Baixe uma cópia dos seus dados pessoais';

  @override
  String get exportDataLoading => 'Coletando seus dados...';

  @override
  String get feedbackCatBug => 'Relatar Bug';

  @override
  String get feedbackCatContent => 'Conteúdo';

  @override
  String get feedbackCatDesign => 'Design';

  @override
  String get feedbackCatFeature => 'Sugerir Função';

  @override
  String get feedbackCatGeneral => 'Geral';

  @override
  String get feedbackCategory => 'Categoria';

  @override
  String get feedbackChangelog => 'Novidades';

  @override
  String get feedbackComments => 'Comentários';

  @override
  String get feedbackConfusing => 'Confuso';

  @override
  String get feedbackContinue => 'Continuar';

  @override
  String get feedbackExcellent => 'Você é incrível!';

  @override
  String get feedbackGood => 'Bom';

  @override
  String get feedbackHard => 'Difícil';

  @override
  String get feedbackHint => 'Conte-nos o que você acha...';

  @override
  String get feedbackHowDidYouFeel => 'Como você se sentiu?';

  @override
  String get feedbackPerfect => 'Perfeito';

  @override
  String get feedbackPoor => 'Vamos melhorar';

  @override
  String get feedbackRateExperience => 'Avalie sua experiência';

  @override
  String get feedbackSubmit => 'Enviar Feedback';

  @override
  String get feedbackTapStars => 'Toque em uma estrela para avaliar';

  @override
  String get feedbackThanks => 'Obrigado!';

  @override
  String get feedbackThanksDesc =>
      'Seu feedback nos ajuda a melhorar o SAGEN para todos.';

  @override
  String get feedbackTitle => 'Feedback e Atualizações';

  @override
  String get fileAnalyzer => 'Analisador de Arquivos';

  @override
  String get fileDangerous => 'Perigoso';

  @override
  String get fileHighRisk => 'Alto risco';

  @override
  String get fileLowRisk => 'Baixo risco';

  @override
  String get fileMediumRisk => 'Risco médio';

  @override
  String get fileSafe => 'Seguro';

  @override
  String get finishText => 'Finalizar';

  @override
  String firstLessonProgress(Object current, Object total) {
    return 'Lição $current de $total';
  }

  @override
  String get firstLessonSeeResults => 'VER RESULTADOS';

  @override
  String get flexCardJoinAlliance => 'Junte-se à minha aliança no SAGEN';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeSmall => 'Pequeno';

  @override
  String get fontSizeTitle => 'Tamanho do texto';

  @override
  String get fontSizeXLarge => 'Extra grande';

  @override
  String get forceSync => 'Forçar Sincronização';

  @override
  String get free => 'Grátis';

  @override
  String get french => 'Francês';

  @override
  String get gachaChestTap => 'Baú gacha. Toque para melhorar.';

  @override
  String get gachaOrbFail => 'Sem alteração';

  @override
  String get gachaOrbSuccess => 'Melhoria bem-sucedida';

  @override
  String get gems => 'gemas';

  @override
  String goToLesson(Object title) {
    return 'Ir para lições: $title';
  }

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get habitMsg1 =>
      'Ótimo trabalho! Agora vamos fortalecer sua disciplina diária.';

  @override
  String get habitMsg2 =>
      'Primeiro passo concluído. Vamos construir o hábito que te leva ao objetivo.';

  @override
  String get habitMsg3 =>
      'Desempenho excelente. O segredo agora é a consistência.';

  @override
  String get habitMsg4 =>
      'Muito bem! Vamos definir seu ritmo de progresso diário.';

  @override
  String get habitMsg5 =>
      'Um começo perfeito. Vamos garantir seu sucesso criando um hábito inabalável.';

  @override
  String get habitTransition1 => 'Construindo seu hábito diário...';

  @override
  String get habitTransition2 => 'A consistência é a chave';

  @override
  String get habitTransition3 => 'Você está progredindo';

  @override
  String get habitTransition4 => 'Continue!';

  @override
  String get habitTransition5 => 'Quase lá!';

  @override
  String get hapticFeedback => 'Resposta Tátil';

  @override
  String get hapticSubtitle => 'Resposta tátil nas interações';

  @override
  String get heatmapLess => 'Menos';

  @override
  String heatmapLessons(Object count) {
    return '$count lições';
  }

  @override
  String get heatmapMore => 'Mais';

  @override
  String get heatmapTitle => 'Atividade recente';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get historyDeleted => 'Histórico excluído';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get homeAllComplete => 'Tudo completo!';

  @override
  String get homeAllCompleteDesc => 'Você dominou todas as lições.';

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeDefaultName => 'Guardião';

  @override
  String levelUpCelebrationLabel(int level) {
    return 'Subiu de nível! Novo nível: $level';
  }

  @override
  String get homeLearningPath => 'Caminho de aprendizado';

  @override
  String get homeTitle => 'Seu escudo digital está ativo';

  @override
  String get homeViewAchievements => 'Ver conquistas';

  @override
  String get howItWorks => 'Como o SAGEN funciona';

  @override
  String get impactAch => 'Conquistas';

  @override
  String get impactActiveUsers => 'Usuários ativos';

  @override
  String get impactCommunity => 'Impacto Comunitário';

  @override
  String get impactCountriesReached => 'Países alcançados';

  @override
  String get impactDonations => 'Total Doado';

  @override
  String get impactHoursLearned => 'Horas aprendidas';

  @override
  String get impactKnowledgeLevel => 'Conhecimento em cibersegurança';

  @override
  String get impactLearningJourney => 'Jornada de Aprendizado';

  @override
  String get impactLessons => 'Lições feitas';

  @override
  String get impactLevelActiveLearner => 'Aprendiz Ativo';

  @override
  String get impactLevelAwareUser => 'Usuário Consciente';

  @override
  String get impactLevelBeginner => 'Começando';

  @override
  String get impactLevelCybersecurityExpert => 'Especialista em Cibersegurança';

  @override
  String get impactLevelDigitalGuardian => 'Guardião Digital';

  @override
  String impactProgressToNext(Object count) {
    return '$count lições para o próximo nível';
  }

  @override
  String get impactProtectedUsers => 'Usuários protegidos';

  @override
  String get impactQuestionsAnswered => 'Perguntas respondidas';

  @override
  String get impactStreak => 'Sequência atual';

  @override
  String get impactTestimonial => 'O que os usuários dizem';

  @override
  String get impactTestimonial1 =>
      'O SAGEN me ajudou a proteger minha família do phishing. As lições interativas são incríveis!';

  @override
  String get impactTestimonial2 =>
      'Passei de não saber nada sobre cibersegurança a ajudar meus colegas a ficarem seguros online.';

  @override
  String get impactTestimonial3 =>
      'A gamificação torna o aprendizado divertido. Concluí 30 lições em apenas 2 semanas!';

  @override
  String get impactTitle => 'Meu Impacto';

  @override
  String get impactTotalLessons => 'Lições concluídas';

  @override
  String get impactXp => 'XP ganhos';

  @override
  String get impactYourLevel => 'SEU NÍVEL';

  @override
  String get impactYourStats => 'Suas Estatísticas';

  @override
  String get incorrect => 'Incorreto';

  @override
  String get incorrectAnswer => 'Resposta incorreta';

  @override
  String get infoSection => 'Informações';

  @override
  String get initialAction => 'Comece aqui';

  @override
  String get inventoryFocusElixir => 'Elixir de Foco';

  @override
  String get inventoryFocusElixirActivated =>
      'Elixir de Foco ativado — x2 por 15 min';

  @override
  String get inventoryFocusElixirDesc => 'Multiplica EXP x2 por 15 min';

  @override
  String get inventoryMonocleAvailable =>
      'Monóculo do Sage disponível para o próximo desafio';

  @override
  String get inventoryPhoenixFeather => 'Pena de Fênix';

  @override
  String get inventoryPhoenixFeatherDesc =>
      'Revive sua sequência se perdida há menos de 24h';

  @override
  String get inventoryPhoenixFeatherRestored =>
      'Pena de Fênix: sequência restaurada';

  @override
  String get inventorySagesMonocle => 'Monóculo do Sábio';

  @override
  String get inventorySagesMonocleDesc =>
      'Remove 2 respostas incorretas em um desafio';

  @override
  String get inventoryShieldProtected =>
      'Escudo de Titânio: sequência protegida';

  @override
  String get inventoryTitaniumShield => 'Escudo de Titânio';

  @override
  String get inventoryTitaniumShieldDesc =>
      'Protege sua sequência automaticamente se faltar um dia';

  @override
  String get inventoryTitle => 'Inventário';

  @override
  String get inventoryUse => 'Usar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get lastSync => 'Última sincronização';

  @override
  String get learnSubtitle => 'Lições interativas de segurança digital';

  @override
  String get learnTitle => 'Aprender';

  @override
  String get learningPath => 'Seu caminho de aprendizado';

  @override
  String get legalAnd => ' e ';

  @override
  String get legalPrivacy => 'Aceito a política de privacidade';

  @override
  String get legalRegisterAgree => 'Ao se registrar, você aceita nossos ';

  @override
  String get legalTerms => 'Termos';

  @override
  String get lessonComplete => 'Lição concluída';

  @override
  String get lessonNoQuestions => 'Nenhuma pergunta disponível para esta lição';

  @override
  String get lessonNoQuestionsHint =>
      'Sage também está curioso! Volte em breve.';

  @override
  String get lessonPreparing => 'Preparando suas perguntas...';

  @override
  String lessonProgress(Object percent) {
    return 'Progresso: $percent%';
  }

  @override
  String get lessonResultsPreparing => 'Preparando resultados...';

  @override
  String lessonsCompleted(Object count) {
    return '$count lições concluídas';
  }

  @override
  String lessonsCompletedPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# lições concluídas',
      one: '# lição concluída',
    );
    return '$_temp0';
  }

  @override
  String lessonsCount(Object count) {
    return '$count lições';
  }

  @override
  String lessonsLevel(Object level) {
    return 'Nível $level';
  }

  @override
  String get lessonsNoAvailable => 'Nenhuma lição disponível. Volte em breve.';

  @override
  String get lessonsYourPath => 'Seu caminho de aprendizado';

  @override
  String get levelAssessment0 => 'Iniciante absoluto';

  @override
  String get levelAssessment1 => 'Iniciante';

  @override
  String get levelAssessment2 => 'Intermediário';

  @override
  String get levelAssessment3 => 'Avançado';

  @override
  String get levelAssessment4 => 'Especialista';

  @override
  String get levelAssessmentQuestion =>
      'Qual é o seu nível atual em cibersegurança?';

  @override
  String levelProgress(Object percent) {
    return 'Progresso do nível: $percent por cento';
  }

  @override
  String get loading => 'Carregando';

  @override
  String get madeWithLove => 'Feito com ♥ para estudantes';

  @override
  String get miniGameBackupDef => 'Cópia de segurança';

  @override
  String get miniGameComplete => 'Concluído!';

  @override
  String get miniGameCorrect => 'Correto';

  @override
  String get miniGameEncryptionDef => 'Proteção de dados com chave';

  @override
  String get miniGameEncryptionTerm => 'Criptografia';

  @override
  String get miniGameFirewallDef => 'Barreira de segurança de rede';

  @override
  String get miniGameHiddenCard => 'Carta oculta';

  @override
  String get miniGameMalwareDef => 'Software malicioso';

  @override
  String get miniGameMatches => 'Correspondências';

  @override
  String get miniGameMemory => 'Memory Match';

  @override
  String get miniGameMemoryDesc => 'Encontre os pares de cartas';

  @override
  String get miniGameMistakes => 'Erros';

  @override
  String get miniGameMoves => 'Movimentos';

  @override
  String get miniGameOver => 'Boa tentativa!';

  @override
  String get miniGamePattern => 'Pattern Trace';

  @override
  String get miniGamePatternDesc => 'Memorize e reproduza padrões';

  @override
  String get miniGamePhishingDef => 'E-mail falso que rouba dados';

  @override
  String get miniGamePlayAgain => 'Jogar novamente';

  @override
  String get miniGameRound => 'Rodada';

  @override
  String get miniGameScore => 'Pontuação';

  @override
  String get miniGameSortInstruction =>
      'Toque para classificar cada item na categoria correta';

  @override
  String get miniGameSpeed => 'Speed Sort';

  @override
  String get miniGameSpeedDesc => 'Classifique itens rapidamente';

  @override
  String get miniGameSubtitle => 'Pratique suas habilidades de cibersegurança';

  @override
  String get miniGameTitle => 'Mini Jogos';

  @override
  String get miniGameVpnDef => 'Rede privada virtual';

  @override
  String get miniGameWatch => 'Observe';

  @override
  String get miniGameWord => 'Word Match';

  @override
  String get miniGameWordDesc => 'Relacione termos com definições';

  @override
  String get miniGameWrong => 'Errado';

  @override
  String get miniGameYourTurn => 'Sua vez';

  @override
  String minutes(Object min) {
    return '$min min';
  }

  @override
  String minutesPerDay(Object count) {
    return '$count minutos por dia';
  }

  @override
  String get missionActiveLearnerDesc => 'Complete 1 lição de segurança.';

  @override
  String get missionActiveLearnerTitle => 'Aprendiz Ativo';

  @override
  String get missionActiveStreakDesc =>
      'Mantenha sua sequência de aprendizado hoje.';

  @override
  String get missionActiveStreakTitle => 'Sequência Ativa';

  @override
  String get missionChatWithSageDesc =>
      'Fale com Sage sobre segurança digital.';

  @override
  String get missionChatWithSageTitle => 'Converse com Sage';

  @override
  String get missionConsistentProtectorDesc => 'Complete 3 lições hoje.';

  @override
  String get missionConsistentProtectorTitle => 'Protetor consistente';

  @override
  String get missionDigitalDetectiveDesc => 'Analise um link suspeito.';

  @override
  String get missionDigitalDetectiveTitle => 'Detetive Digital';

  @override
  String get missionExpressChallengeDesc =>
      'Complete um desafio rápido de 30 segundos.';

  @override
  String get missionExpressChallengeTitle => 'Desafio Express';

  @override
  String get missionPerfectLessonDesc => 'Complete uma lição sem erros.';

  @override
  String get missionPerfectLessonTitle => 'Lição Perfeita';

  @override
  String get missionPhishingHunterDesc =>
      'Detecte corretamente uma tentativa de phishing.';

  @override
  String get missionPhishingHunterTitle => 'Caçador de Phishing';

  @override
  String missionProgress(Object percent) {
    return 'Progresso da missão: $percent por cento';
  }

  @override
  String get missionThreeQueriesDesc =>
      'Fale com Sage 3 vezes sobre diferentes tópicos.';

  @override
  String get missionThreeQueriesTitle => '3 consultas';

  @override
  String get monthApr => 'Abr';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthAug => 'Ago';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthDec => 'Dez';

  @override
  String get monthDecember => 'Dezembro';

  @override
  String get monthFeb => 'Fev';

  @override
  String get monthFebruary => 'Fevereiro';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthJanuary => 'Janeiro';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthJuly => 'Julho';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJune => 'Junho';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthMarch => 'Março';

  @override
  String get monthMay => 'Maio';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthNovember => 'Novembro';

  @override
  String get monthOct => 'Out';

  @override
  String get monthOctober => 'Outubro';

  @override
  String get monthSep => 'Set';

  @override
  String get monthSeptember => 'Setembro';

  @override
  String get motivationCareer => 'Carreira profissional';

  @override
  String get motivationConnect => 'Me conectar com pessoas';

  @override
  String get motivationDialogMultiple => 'Múltiplas motivações selecionadas';

  @override
  String get motivationDialogNone => 'Nenhuma motivação selecionada';

  @override
  String get motivationFun => 'Me divertir';

  @override
  String get motivationMind => 'Exercitar minha mente';

  @override
  String get motivationOther => 'Outro';

  @override
  String get motivationStudies => 'Estudos';

  @override
  String get motivationTravel => 'Viajar';

  @override
  String get myAccount => 'Minha Conta';

  @override
  String get navChest => 'Baú';

  @override
  String get navHome => 'Início';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navSage => 'Sage';

  @override
  String get never => 'Nunca';

  @override
  String get newBadge => 'NOVO';

  @override
  String get newsUpdates => 'Novidades e Atualizações';

  @override
  String get nextText => 'Próximo';

  @override
  String get noConnection => 'Sem conexão com a internet.';

  @override
  String get noLessonsAvailable => 'Nenhuma lição disponível';

  @override
  String get notFoundBackHome => 'Voltar ao início';

  @override
  String get notFoundDescription => 'A página que você procura não existe.';

  @override
  String get notFoundTitle => 'Página não encontrada';

  @override
  String get notificationReminder =>
      'Cinco minutos hoje podem ajudar você amanhã.';

  @override
  String get notificationStreakAlive => 'Sua sequência ainda está viva!';

  @override
  String get notificationStreakLoss => 'Nunca é tarde para recomeçar.';

  @override
  String get notificationTip => 'Seu escudo digital está esperando por você.';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get offlineAction => 'Conecte-se e tente novamente.';

  @override
  String get offlineMessage => 'Sem conexão com a internet.';

  @override
  String get offlineNoConnection => 'Sem conexão com a internet';

  @override
  String get offlineSavedForLater => 'Salvo offline. Sincronizaremos em breve.';

  @override
  String get offlineSyncComplete => 'Sincronização concluída!';

  @override
  String get onbDiagnosisMsg =>
      'Ótimo! Ajustaremos seu plano de treinamento para proteger seu conhecimento desde o primeiro dia.';

  @override
  String get onbGoalCommit => 'MANTER MEU COMPROMISSO';

  @override
  String get onbGoalIntense => 'Intenso';

  @override
  String onbGoalMinPerDay(Object minutes) {
    return '$minutes min/dia';
  }

  @override
  String get onbGoalNormal => 'Normal';

  @override
  String get onbGoalRelaxed => 'Tranquilo';

  @override
  String get onbGoalSerious => 'Sério';

  @override
  String get onbGoalTitle => 'Qual é sua meta diária de aprendizado?';

  @override
  String get onbLevel0 => 'Zero absoluto (Não sei o que é phishing...)';

  @override
  String get onbLevel1 => 'Conheço o básico...';

  @override
  String get onbLevel2 => 'Nível intermediário...';

  @override
  String get onbLevel3 => 'Nível avançado...';

  @override
  String get onbLevel4 => 'Especialista em cibersegurança...';

  @override
  String get onbLevelContinue => 'CONTINUAR';

  @override
  String get onbLevelQuestion => 'Qual é o seu nível atual em cibersegurança?';

  @override
  String get onbLevelTitle => 'Qual é seu nível atual em cibersegurança?';

  @override
  String get onbMotivationCareer => 'Carreira profissional';

  @override
  String get onbMotivationCareerMsg => 'Excelentes razões para aprender!';

  @override
  String get onbMotivationConnect => 'Me conectar com pessoas';

  @override
  String get onbMotivationConnectMsg => 'Vamos te preparar para se conectar!';

  @override
  String get onbMotivationFun => 'Me divertir';

  @override
  String get onbMotivationFunMsg => 'Amei! Diversão é minha especialidade.';

  @override
  String get onbMotivationMind => 'Exercitar minha mente';

  @override
  String get onbMotivationMindMsg => 'É uma decisão sábia.';

  @override
  String get onbMotivationOther => 'Outro';

  @override
  String get onbMotivationOtherMsg =>
      'Entendido! Conte-me mais ao longo do caminho.';

  @override
  String get onbMotivationStudies => 'Estudos';

  @override
  String get onbMotivationStudiesMsg =>
      'Um mundo de oportunidades se abrirá para você!';

  @override
  String get onbMotivationTitle =>
      'Por que você tem interesse em dominar o mundo digital?';

  @override
  String get onbMotivationTravel => 'Viajar';

  @override
  String get onbMotivationTravelMsg =>
      'Nada melhor que viajar com seus dispositivos 100% protegidos!';

  @override
  String get onbNotifActivate => 'ATIVAR NOTIFICAÇÕES';

  @override
  String get onbNotifDesc =>
      'Ative as notificações para nunca perder sua sequência, lembretes diários e desafios importantes.';

  @override
  String get onbNotifSkip => 'Agora não';

  @override
  String get onbNotifTitle => 'Avisamos você?';

  @override
  String get onbProjHackerMind => 'Forje uma mente de hacker';

  @override
  String get onbProjHackerMindDesc =>
      'Lembretes estratégicos, desafios diários e táticas de defesa digital.';

  @override
  String get onbProjLockAccounts => 'Proteja suas contas';

  @override
  String get onbProjLockAccountsDesc =>
      'Proteja suas redes sociais e contas de jogos contra hackers e roubos.';

  @override
  String get onbProjNavImmunity => 'Navegue com imunidade';

  @override
  String get onbProjNavImmunityDesc =>
      'Detecte golpes, links maliciosos e phishing antes de clicar.';

  @override
  String get onbProjectionTitle => 'Isso é o que você vai dominar em 3 meses!';

  @override
  String onbQuizIntro(Object count) {
    return 'Responda $count perguntas rápidas antes do seu primeiro treinamento digital!';
  }

  @override
  String get onbRecommended => 'RECOMENDADO';

  @override
  String get onbReferralFriends => 'Recomendação de amigos';

  @override
  String get onbReferralGoogle => 'Pesquisa Google';

  @override
  String get onbReferralOther => 'Outro';

  @override
  String get onbReferralPlayStore => 'Play Store';

  @override
  String get onbReferralQuestion => 'Como você descobriu o SAGEN?';

  @override
  String get onbReferralSocial => 'Instagram / Facebook';

  @override
  String get onbReferralTiktok => 'TikTok';

  @override
  String get onbReferralTitle => 'Como você descobriu o SAGEN?';

  @override
  String get onbReferralYoutube => 'YouTube';

  @override
  String get onbRouteAvailable => 'Rotas de treinamento disponíveis:';

  @override
  String get onbRouteQuestion =>
      'Qual área do ambiente digital você gostaria de dominar primeiro?';

  @override
  String get onbRoutineMessage =>
      'Escolha sua rotina de treinamento e proteção!';

  @override
  String get onbRoutineTitle => 'Escolha sua rotina de treinamento e proteção!';

  @override
  String get onbStartingExperienced => 'Já tem nível de hacker?';

  @override
  String get onbStartingExperiencedSub =>
      'Faça o teste de nível e pule o básico!';

  @override
  String get onbStartingPerfecto =>
      'Perfeito! Vamos ver por onde começar seu treinamento.';

  @override
  String get onbStartingSubtitle => 'Comece do zero e forje seu escudo!';

  @override
  String get onbStartingTitle => 'É sua primeira vez na ciberdefesa?';

  @override
  String get onbWelcomeMessage =>
      'Olá! Eu sou o Sagen. Estou aqui para treinar você, proteger seu ambiente digital e torná-lo um especialista.';

  @override
  String get onbWelcomeMsg =>
      'Olá! Sou o Sagen. Estou aqui para treinar você, proteger seu ambiente digital e torná-lo um especialista.';

  @override
  String get onboardingCommitButton => 'MANTER MEU COMPROMISSO';

  @override
  String get onboardingComplete =>
      'Ótimo! Agora você sabe detectar phishing básico.';

  @override
  String get onboardingDesc =>
      'Seu assistente pessoal de segurança digital.\nAprenda, analise e proteja-se gratuitamente.';

  @override
  String get onboardingError =>
      'É assim que eles agem. Eles sempre verificam antes de confiar.';

  @override
  String get onboardingHaveAccount => 'Já tenho uma conta';

  @override
  String get onboardingSage50Days =>
      '50 dias de dedicação. Uma lenda em formação!';

  @override
  String get onboardingSageExcellent => 'Excelentes razões, mire alto!';

  @override
  String get onboardingSageMonth =>
      'Um mês de disciplina. Hábitos são forjados.';

  @override
  String get onboardingSageStart => 'Um ótimo começo! Cada dia conta.';

  @override
  String get onboardingSageTwoWeeks =>
      'Duas semanas de consistência. Você é imbatível!';

  @override
  String get onboardingWelcome => 'Aprenda a se proteger';

  @override
  String get onboardingWelcomeDesc =>
      'SAGEN te ensina a navegar, detectar riscos e proteger suas informações na internet.';

  @override
  String get ourMission => 'Nossa Missão';

  @override
  String get owned => 'Obtido';

  @override
  String get passClaimFailed =>
      'Não foi possível resgatar a recompensa. Tente novamente.';

  @override
  String get passClaimedLabel => 'Resgatado';

  @override
  String passDaysLeft(Object count) {
    return 'Faltam $count dias';
  }

  @override
  String get passEarnSp => 'Ganhe SP concluindo lições';

  @override
  String get passHowToEarnDailyLimit => 'Limite diário de SP';

  @override
  String get passHowToEarnLesson => 'Conclua uma lição: +10 SP';

  @override
  String get passHowToEarnMission => 'Conclua missões diárias: +5 SP';

  @override
  String get passHowToEarnPerfect => 'Lição perfeita: +15 SP';

  @override
  String get passHowToEarnReview => 'Revise uma lição';

  @override
  String get passHowToEarnTitle => 'Como ganhar SP';

  @override
  String passLevel(Object level) {
    return 'Nível $level';
  }

  @override
  String get passLevelsTitle => 'Níveis';

  @override
  String get passLocked => 'Bloqueado';

  @override
  String get passMaxLevel => 'Nível máximo!';

  @override
  String passProgress(Object current, Object required) {
    return 'SP: $current / $required';
  }

  @override
  String get passReached => 'Alcançado';

  @override
  String get passRewardClaimed => 'Recompensa resgatada!';

  @override
  String passRewards(Object current, Object max) {
    return 'Recompensas ($current/$max)';
  }

  @override
  String get paymentCredited => 'Creditado!';

  @override
  String get paymentGoHome => 'Ir para o início';

  @override
  String get paymentMercadoPagoError =>
      'Erro ao conectar ao MercadoPago. Tente novamente.';

  @override
  String get paymentNotCompleted => 'Pagamento não concluído';

  @override
  String get paymentPending => 'Pagamento pendente';

  @override
  String get paymentPendingDescription =>
      'Seu pagamento está sendo processado. As doações serão creditadas assim que o pagamento for confirmado pelo fornecedor.';

  @override
  String get paymentReturnToSagen => 'Voltar ao SAGEN';

  @override
  String get paymentTryAgain => 'Tentar novamente';

  @override
  String get paymentErrorNotSignedIn =>
      'Você precisa estar conectado para doar.';

  @override
  String get paymentErrorSessionExpired =>
      'Sessão expirada. Faça login novamente.';

  @override
  String get paymentErrorInvalidProduct => 'Produto inválido.';

  @override
  String get paymentErrorStartFailed =>
      'Não foi possível iniciar o pagamento. Tente novamente.';

  @override
  String get paymentErrorRegisterFailed =>
      'Não foi possível registrar o pagamento. Tente novamente.';

  @override
  String get paymentErrorExpired => 'O pagamento expirou. Tente novamente.';

  @override
  String get paymentErrorCancelled =>
      'O pagamento foi cancelado ou não foi concluído.';

  @override
  String get paywallBasic => 'Básico';

  @override
  String get paywallDescription =>
      'Escolha seu pacote e entraremos em contato via WhatsApp para coordenar o pagamento.';

  @override
  String get paywallMercadoPago => 'Mercado Pago';

  @override
  String paywallPackageAmount(Object gems) {
    return '$gems doações';
  }

  @override
  String paywallPackageLabel(Object label) {
    return 'Pacote $label';
  }

  @override
  String paywallPackageSupporter(Object level) {
    return 'Nível de Supporter $level';
  }

  @override
  String get paywallPaymentMethods =>
      'Pague com Yape, Plin, MercadoPago ou transferência';

  @override
  String get paywallPopular => 'Popular';

  @override
  String get paywallPremium => 'Premium';

  @override
  String get paywallSupportUs => 'Apoiar o SAGEN';

  @override
  String paywallWhatsAppError(Object link) {
    return 'Erro ao abrir WhatsApp. Pagar via: $link';
  }

  @override
  String paywallWhatsAppFallback(Object message) {
    return 'Abra o WhatsApp e envie: $message';
  }

  @override
  String paywallWhatsAppMessage(
    Object currencySymbol,
    Object supporterLevel,
    Object price,
    Object userId,
  ) {
    return 'Olá, quero doar $currencySymbol$price para SAGEN (Supporter $supporterLevel). Meu ID de usuário é: $userId';
  }

  @override
  String get portuguese => 'Português';

  @override
  String get preferencesTitle => 'Preferências';

  @override
  String get preparingResults => 'Preparando resultados...';

  @override
  String get privacyLegal => 'Privacidade e Legal';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get privacyPolicyTitle => 'Política de Privacidade do SAGEN';

  @override
  String get privacyPolicyLastUpdate => 'Última atualização: Julho de 2026';

  @override
  String get privacyPolicySection1Title => '1. Informações que Coletamos';

  @override
  String get privacyPolicySection1Body =>
      'Coletamos informações que você fornece diretamente, como seu nome, email e idade, além de dados de uso do app como lições concluídas, sequências e pontuações.';

  @override
  String get privacyPolicySection2Title => '2. Uso das Informações';

  @override
  String get privacyPolicySection2Body =>
      'Usamos suas informações para personalizar sua experiência de aprendizado, melhorar nossos serviços e enviar notificações relevantes sobre seu progresso.';

  @override
  String get privacyPolicySection3Title => '3. Armazenamento de Dados';

  @override
  String get privacyPolicySection3Body =>
      'Seus dados são armazenados de forma segura em servidores protegidos. Usamos criptografia para proteger suas informações pessoais.';

  @override
  String get privacyPolicySection4Title => '4. Seus Direitos';

  @override
  String get privacyPolicySection4Body =>
      'Você tem o direito de acessar, retificar ou excluir seus dados pessoais. Você pode nos contatar para exercer esses direitos.';

  @override
  String get privacyPolicySection5Title => '5. Terceiros';

  @override
  String get privacyPolicySection5Body =>
      'Não vendemos suas informações a terceiros. Podemos compartilhar dados anonimizados para melhorar nossos serviços educacionais.';

  @override
  String get privacyPolicySection6Title => '6. Privacidade de Crianças';

  @override
  String get privacyPolicySection6Body =>
      'Nosso app é voltado para adultos. Não coletamos intencionalmente informações de crianças menores de 13 anos.';

  @override
  String get privacyPolicySection7Title => '7. Segurança';

  @override
  String get privacyPolicySection7Body =>
      'Implementamos medidas de segurança técnicas e organizacionais para proteger suas informações contra acesso não autorizado.';

  @override
  String get privacyPolicySection8Title => '8. Alterações nesta Política';

  @override
  String get privacyPolicySection8Body =>
      'Reservamo-nos o direito de atualizar esta política. Notificaremos você sobre alterações significativas através do app.';

  @override
  String get privacyPolicySection9Title => '9. Contato';

  @override
  String get privacyPolicySection9Body =>
      'Se você tiver dúvidas sobre esta política, entre em contato conosco em support@sagenapp.com';

  @override
  String get productBestOffer => 'Melhor oferta';

  @override
  String get productBoost => 'Impulso';

  @override
  String get productBoostPack => 'Pacote Impulso';

  @override
  String get productBoostPackDesc => '200 doações + 1 Boost de XP';

  @override
  String get productDonationBasic => 'Supporter';

  @override
  String get productDonationDesc => 'Ajude-nos a manter o SAGEN gratuito';

  @override
  String get productDonationPremium => 'Campeão';

  @override
  String get productDonationStandard => 'Super Supporter';

  @override
  String get productDonations => 'Doações';

  @override
  String get productDonationsDesc => 'Doações para impulsionar seu aprendizado';

  @override
  String get productFortune => 'Fortuna';

  @override
  String get productFortunePack => 'Pacote Fortuna';

  @override
  String get productFortunePackDesc => '300 doações + 1 Multiplicador de XP';

  @override
  String get productLuck => 'Sorte';

  @override
  String get productLuckBoostDesc => '1 Boost de Sorte (2x nos baús lendários)';

  @override
  String get productLuckPack => 'Pacote Sorte';

  @override
  String get productLuckPackDesc => '250 doações + 1 Boost de Sorte';

  @override
  String get productOffer => 'Oferta';

  @override
  String get productPopular => 'Popular';

  @override
  String get productProtector => 'Protetor';

  @override
  String get productProtectorPack => 'Pacote Protetor';

  @override
  String get productProtectorPackDesc =>
      '100 doações + 1 protetor de sequência';

  @override
  String get productStreakProtectorDesc => '1 Protetor de sequência';

  @override
  String get productSupporter => 'Supporter';

  @override
  String get productUltra => 'Ultra';

  @override
  String get productXpBoostDesc => '1 Boost de XP (2x na sua próxima lição)';

  @override
  String get productXpMultiplierDesc => '1 Multiplicador de XP (2x nos baús)';

  @override
  String get profileAchievements => 'Conquistas';

  @override
  String get profileDay => 'dia';

  @override
  String get profileDays => 'dias';

  @override
  String get profileDefaultFirstName => 'Guerreiro';

  @override
  String get profileDefaultLastName => 'Anônimo';

  @override
  String get profileDefaultName => 'Guardião';

  @override
  String get profileDonations => 'Doações';

  @override
  String get profileError => 'Erro ao carregar perfil';

  @override
  String get profileLevel => 'Nível';

  @override
  String profileLevelValue(Object level) {
    return 'Nível $level';
  }

  @override
  String get profileStreak => 'Sequência';

  @override
  String get profileGemsEarned => 'Ganhas';

  @override
  String get profileGemsSpent => 'Gastas';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileTotalXp => 'XP Total';

  @override
  String get profileXpLabel => 'XP';

  @override
  String xpValue(int count) {
    return '$count XP';
  }

  @override
  String get progressRestored => 'Progresso restaurado da nuvem';

  @override
  String get projectionBenefit1Subtitle =>
      'Proteja suas redes sociais e e-mails';

  @override
  String get projectionBenefit1Title => 'Proteja suas contas';

  @override
  String get projectionBenefit2Subtitle =>
      'Identifique phishing e links maliciosos';

  @override
  String get projectionBenefit2Title => 'Detecte golpes';

  @override
  String get projectionBenefit3Subtitle => 'Navegue na internet com confiança';

  @override
  String get projectionBenefit3Title => 'Navegue com segurança';

  @override
  String get promoPostLessonSubtitle =>
      'Com SAGEN Pass, obtenha benefícios exclusivos';

  @override
  String get promoPostLessonTitle => 'Continue assim! Desbloqueie mais';

  @override
  String get protectionBasic => 'Básico';

  @override
  String get protectionBasicDesc => 'Você começa a se proteger';

  @override
  String get protectionCyberShield => 'Cyber Escudo';

  @override
  String get protectionCyberShieldDesc => 'Você é um escudo ativo';

  @override
  String get protectionElite => 'Proteção Elite';

  @override
  String get protectionEliteDesc => 'Nível máximo de proteção';

  @override
  String get protectionGuardian => 'Guardião';

  @override
  String get protectionGuardianDesc => 'Você defende sua identidade digital';

  @override
  String get protectionProtected => 'Protegido';

  @override
  String get protectionProtectedDesc => 'Seus primeiros hábitos digitais';

  @override
  String get protectionSecureMind => 'Secure Mind';

  @override
  String get protectionSecureMindDesc => 'A segurança faz parte de você';

  @override
  String questionProgress(Object current, Object total) {
    return 'Pergunta $current de $total';
  }

  @override
  String questions(Object count) {
    return '$count perguntas';
  }

  @override
  String get quickActions => 'Ações rápidas';

  @override
  String get quickChallengeDetectPhishing => 'Detecte phishing';

  @override
  String get quickChallengeDetectRisk => 'Detecte o risco';

  @override
  String get quickChallengeSafePassword => 'Senha segura';

  @override
  String get quickChallengeTrueFalse => 'Verdadeiro ou Falso';

  @override
  String get quickChallengeWhatWouldYouDo => 'O que você faria?';

  @override
  String get quizAbandonContent => 'Você perderá seu progresso atual.';

  @override
  String get quizAbandonExit => 'SAIR';

  @override
  String get quizAbandonMessage => 'Você perderá seu progresso atual.';

  @override
  String get quizAbandonStay => 'CONTINUAR';

  @override
  String get quizAbandonTitle => 'Desistir?';

  @override
  String get quizBack => 'Voltar';

  @override
  String get quizCheck => 'VERIFICAR';

  @override
  String get quizCheckAnswer => 'VERIFICAR';

  @override
  String get quizContinue => 'CONTINUAR';

  @override
  String get quizContinueButton => 'CONTINUAR';

  @override
  String get quizDefaultTitle => 'Questionário';

  @override
  String get quizExit => 'SAIR';

  @override
  String get quizIntroAnswer => 'Responda';

  @override
  String get quizIntroBeforeTraining => 'Antes do seu treinamento';

  @override
  String get quizIntroFastQuestions => 'Perguntas rápidas';

  @override
  String quizProgress(Object percent) {
    return 'Progresso do questionário: $percent por cento';
  }

  @override
  String get quizProgressExpired =>
      'O progresso do quiz expirou (mais de 24 horas).';

  @override
  String get quizResumeButton => 'Retomar';

  @override
  String get quizStartOver => 'Começar de novo';

  @override
  String get quizTitleDefault => 'Quiz';

  @override
  String get rankActiveLearner => 'Aprendiz Ativo';

  @override
  String get rankCybersecurityLegend => 'Lenda da Cibersegurança';

  @override
  String get rankEliteDefender => 'Defensor de Elite';

  @override
  String get rankExperiencedWarrior => 'Guerreiro Experiente';

  @override
  String get rankNovice => 'Novato';

  @override
  String get rankingEmptyMessage => 'Conclua lições para entrar no ranking';

  @override
  String get rankingError => 'Erro ao carregar ranking';

  @override
  String rankingPosition(Object rank) {
    return 'Posição #$rank';
  }

  @override
  String get rankingShareButton => 'Compartilhar Flex Card';

  @override
  String get rankingShareSubtitle => 'Supere meu ranking no SAGEN';

  @override
  String get rankingSharing => 'Compartilhando...';

  @override
  String get rankingSubtitle => 'Ranking global · Top 50';

  @override
  String get rankingTitle => 'O Coliseu';

  @override
  String rankingXpToTop50(Object xp) {
    return 'Você precisa de $xp XP para entrar no Top 50';
  }

  @override
  String rankingYourPosition(Object xp, Object rank) {
    return 'Sua posição: #$rank · $xp XP';
  }

  @override
  String get rarityGold => 'Ouro';

  @override
  String get rarityPlatinum => 'Platina';

  @override
  String get raritySilver => 'Prata';

  @override
  String get reauthConfirm => 'Confirmar';

  @override
  String get reauthDesc => 'Por segurança, digite sua senha novamente';

  @override
  String get reauthOAuthInfo =>
      'Você fez login com Google ou Facebook. Confirme a exclusão da conta.';

  @override
  String get reauthTitle => 'Confirme sua senha';

  @override
  String get reauthWrongPassword => 'Senha incorreta. Tente novamente.';

  @override
  String get recommended => 'RECOMENDADO';

  @override
  String get reduceAnimations => 'Reduzir Animações';

  @override
  String get reduceAnimationsSubtitle => 'Reduz a intensidade das animações';

  @override
  String get referralSource1 => 'Recomendação de amigos';

  @override
  String get referralSource2 => 'Redes sociais';

  @override
  String get referralSource3 => 'Pesquisa Google';

  @override
  String get referralSource4 => 'App Store';

  @override
  String get referralSource5 => 'YouTube';

  @override
  String get referralSource6 => 'TikTok';

  @override
  String get referralSource7 => 'Outro';

  @override
  String get regAgeQuestion => 'Quantos anos você tem?';

  @override
  String get regAgeValidation => 'Por favor, informe sua idade real';

  @override
  String get regChooseMethod => 'Escolha um método para criar sua conta.';

  @override
  String get regCloudSave => 'Progresso salvo na nuvem';

  @override
  String get regCreateProfile => 'CRIAR PERFIL';

  @override
  String get regEmailDesc => 'Enviaremos um código de verificação.';

  @override
  String get regEmailHint => 'exemplo@email.com';

  @override
  String get regEmailOption => 'E-mail';

  @override
  String get regEmailTitle => 'Seu e-mail';

  @override
  String get regHowContinue => 'Como gostaria de continuar?';

  @override
  String get regLater => 'Depois';

  @override
  String get regMethodTitle => 'Escolha o método de registro';

  @override
  String get regNameHint => 'Nome';

  @override
  String get regNameQuestion => 'Qual é o seu nome?';

  @override
  String get regPasswordDesc =>
      'Mínimo de 6 caracteres para proteger sua conta.';

  @override
  String get regPasswordTitle => 'Crie uma senha';

  @override
  String get regProfileAlmostReady => 'Quase pronto!';

  @override
  String get regProfileCreated => 'PERFIL CRIADO';

  @override
  String get regProfileDesc =>
      'Crie um perfil para salvar seu progresso e não perder sua sequência.';

  @override
  String get regReadyForLesson => 'Prepare-se para sua primeira lição';

  @override
  String get regRewards => 'Recompensas e conquistas pessoais';

  @override
  String get regStreakSync => 'Sequência sincronizada entre dispositivos';

  @override
  String get regSurnameHint => 'Sobrenome';

  @override
  String get regWelcomeSagen => 'Bem-vindo ao SAGEN!';

  @override
  String get registerAgeEmpty => 'Por favor, insira sua idade';

  @override
  String get registerAgeHint => 'Sua idade (mínimo 13)';

  @override
  String get registerAgeInvalid => 'Idade inválida';

  @override
  String get registerAgeMin => 'Você deve ter pelo menos 13 anos';

  @override
  String get registerWithApple => 'Registrar com Apple';

  @override
  String get registerWithFacebook => 'Registrar com Facebook';

  @override
  String get registerWithGoogle => 'Registrar com Google';

  @override
  String get restartApp => 'Reiniciar app';

  @override
  String get restoreAction => 'Restaurar';

  @override
  String get restoreCloud => 'Restaurar da Nuvem';

  @override
  String get restoreDesc =>
      'Quer restaurar seu progresso da nuvem? Isso substituirá os dados locais pelos dados salvos da sua conta.';

  @override
  String get restoreTitle => 'Restaurar Progresso';

  @override
  String get resultAccuracy => 'Precisão';

  @override
  String get resultCompleteTitle => 'Lição concluída!';

  @override
  String get resultLives => 'Vidas';

  @override
  String get resultNotPerfectDesc =>
      'Continue praticando para conseguir uma sessão perfeita.';

  @override
  String get resultPerfectBadge => 'SESSÃO PERFEITA';

  @override
  String get resultPerfectDesc =>
      'Você não cometeu nenhum erro. Você é um guardião digital.';

  @override
  String get resultPerfectTitle => 'Resultado impecável!';

  @override
  String get resumeQuiz => 'Retomar quiz?';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get reviewComplete => 'Revisão concluída!';

  @override
  String get reviewCorrect => 'corretas';

  @override
  String get reviewFinish => 'Finalizar revisão';

  @override
  String get reviewGoodProgress => 'Bom progresso';

  @override
  String get reviewKeepGoing => 'Continue assim!';

  @override
  String get reviewKeepPracticing => 'Continue praticando';

  @override
  String get reviewNoErrors => 'Nenhum erro para revisar';

  @override
  String get reviewSageGood =>
      'Cada revisão fortalece seu escudo. Pronto para mais?';

  @override
  String get reviewSageKeep =>
      'Revisar faz parte do aprendizado. Você pode tentar novamente quando quiser.';

  @override
  String get reviewSagePerfect =>
      'Suas áreas fracas estão melhorando. Vejo seu esforço.';

  @override
  String get reviewTitle => 'Revisão';

  @override
  String get reward100Xp => '100 XP';

  @override
  String get reward200Exp => '200 EXP';

  @override
  String rewardAdCooldown(Object seconds) {
    return 'Disponível novamente em $seconds segundos';
  }

  @override
  String rewardAdEarned(Object count) {
    return 'Você ganhou $count doações!';
  }

  @override
  String rewardAdEarnedGems(Object gems) {
    return '+$gems gemas';
  }

  @override
  String rewardAdEarnedXp(Object xp) {
    return '+$xp XP ganhos!';
  }

  @override
  String get rewardAdNotAvailable =>
      'O anúncio não está disponível agora. Tente mais tarde.';

  @override
  String get rewardAdSubtitle =>
      'Assista a um anúncio e receba doações instantaneamente';

  @override
  String get rewardAdTitle => 'Ganhe doações extras';

  @override
  String get rewardAdWatch => 'Assistir';

  @override
  String get rewardCopperFrame => 'Moldura de Cobre';

  @override
  String get rewardEpicChest => 'Baú Épico';

  @override
  String get rewardGoldenChest => 'Baú Dourado';

  @override
  String get rewardIceFlame => 'Chama Gelada + Guardião';

  @override
  String get rewardTitaniumShield => 'Escudo de Titânio';

  @override
  String get routeSelection1 => 'Fundamentos primeiro';

  @override
  String get routeSelection2 => 'Rota intermediária';

  @override
  String get routeSelection3 => 'Rota avançada';

  @override
  String sageAchievementUnlocked(Object name) {
    return '${name}Conquista desbloqueada!';
  }

  @override
  String sageAdvancing(Object levelHint, Object name) {
    return '${name}Você continua avançando.$levelHint';
  }

  @override
  String get sageChatDescription =>
      'Escreva qualquer dúvida sobre cibersegurança ou escolha uma sugestão rápida.';

  @override
  String get sageChatHint => 'Pergunte ao Sage...';

  @override
  String get sageChatTitle => 'Pergunte ao Sage';

  @override
  String sageCongratulations(Object name) {
    return '${name}Parabéns!';
  }

  @override
  String get sageCriticalError => 'Erro crítico';

  @override
  String get sageEasterEgg => 'Você viu isso?';

  @override
  String sageEmptyState(Object name) {
    return '${name}Nada aqui ainda';
  }

  @override
  String sageGreatJob(Object name, Object extra) {
    return '${name}Excelente trabalho!$extra';
  }

  @override
  String sageHighStreakDays(Object streak) {
    return ' $streak dias seguidos.';
  }

  @override
  String get sageImportant => 'Isso é muito importante';

  @override
  String sageImpressiveStreak(Object name, Object days) {
    return '${name}Sequência impressionante!$days';
  }

  @override
  String sageLevelHint(Object level) {
    return ' O nível $level já está perto.';
  }

  @override
  String get sageLoading => 'Dê-me um segundo...';

  @override
  String get sageMascot => 'Mascote Sage';

  @override
  String get sageMonocleActive => 'Monóculo Sábio ativo';

  @override
  String get sageMonocleButton => 'Usar Monóculo Sábio (remove 2 incorretas)';

  @override
  String get sageMotivational1 => 'Você está indo muito bem!';

  @override
  String get sageMotivational2 => 'Continue assim, você é incrível!';

  @override
  String get sageMotivational3 => 'Cada dia mais perto do seu objetivo!';

  @override
  String get sageMotivational4 => 'Eu acredito em você!';

  @override
  String get sageMotivational5 => 'Não desista, você consegue!';

  @override
  String get sageMotivational6 => 'Vamos juntos nesta aventura!';

  @override
  String get sageMotivational7 => 'Esforço dá frutos!';

  @override
  String get sageMotivational8 => 'Nunca pare de aprender!';

  @override
  String get sagePerfect => 'Perfeito!';

  @override
  String get sagePreparing => 'Preparando tudo para você';

  @override
  String get sageReadCarefully => 'Leia com atenção';

  @override
  String get sageSomethingWrong => 'Algo deu errado';

  @override
  String sageStreakAmazing(Object streak) {
    return 'Sua sequência de $streak dias é incrível!';
  }

  @override
  String sageStreakAtRisk(Object streak) {
    return ' Não perca $streak dias de esforço!';
  }

  @override
  String sageStreakAtRiskMessage(Object urgency, Object name) {
    return '${name}Não perca sua sequência!$urgency';
  }

  @override
  String get sageStreakLost => ' Você tem o conhecimento para recomeçar.';

  @override
  String sageStreakLostMessage(Object name, Object encouragement) {
    return '${name}A sequência foi perdida.$encouragement';
  }

  @override
  String sageTellMeMore(Object name) {
    return '${name}Conte-me mais sobre você';
  }

  @override
  String get sageTryAgain => 'Tentar de novo?';

  @override
  String sageWelcomeBack(Object name) {
    return '${name}Bem-vindo de volta!';
  }

  @override
  String sageWhatDoYouThink(Object name) {
    return '${name}O que você acha que está correto?';
  }

  @override
  String get sagenPassClaim => 'Resgatar';

  @override
  String get sagenPassSupportSubtitle =>
      'Obtenha benefícios exclusivos e ajude a melhorar o app';

  @override
  String get sagenPassSupportTitle => 'Apoiar SAGEN';

  @override
  String get sagenPassTitle => 'Passe SAGEN';

  @override
  String get savedQuizProgress =>
      'Você tem um progresso salvo. Gostaria de continuar?';

  @override
  String get scheduledDarkMode => 'Modo Escuro Programado';

  @override
  String get scheduledDarkModeSubtitle =>
      'Ativar/desativar automaticamente conforme horário';

  @override
  String get searchPlaceholder => 'Pesquisar...';

  @override
  String get selectFile => 'Selecionar arquivo';

  @override
  String get selectedAnswer => 'Selecionada';

  @override
  String get sendMessage => 'Enviar';

  @override
  String get sessionAccuracyText1 => 'Que pontaria!';

  @override
  String get sessionAccuracyText2 => 'Precisão cirúrgica.';

  @override
  String get sessionAccuracyText3 => 'Nível especialista alcançado.';

  @override
  String get sessionAccuracyText4 => 'Atirador de elite do conhecimento.';

  @override
  String get sessionAccuracyText5 => 'Precisão quase absoluta.';

  @override
  String get sessionAccuracyText6 => 'Sem margem para erro.';

  @override
  String get sessionAccuracyText7 => 'Impecável.';

  @override
  String get sessionBackToMap => 'Voltar ao mapa';

  @override
  String get sessionClaimReward => 'RECEBER RECOMPENSA';

  @override
  String get sessionCorrect => 'Correto!';

  @override
  String sessionCorrectAnswer(Object answer) {
    return 'Resposta correta: $answer';
  }

  @override
  String get sessionExp => 'XP';

  @override
  String get sessionIncorrect => 'Incorreto';

  @override
  String get sessionLivesExhausted => 'Vidas esgotadas';

  @override
  String get sessionLivesExhaustedDesc =>
      'Você perdeu todas as suas vidas. Tente novamente.';

  @override
  String get sessionLoading => 'Carregando...';

  @override
  String get sessionPrecision => 'PRECISÃO';

  @override
  String get sessionQuestionsToAnswer => 'perguntas para responder';

  @override
  String get sessionReadyToLearn => 'Pronto para aprender?';

  @override
  String get sessionRetry => 'Tentar novamente';

  @override
  String sessionScore(Object correct, Object total) {
    return '$correct/$total corretas';
  }

  @override
  String get sessionSelectAnswer => 'Selecione uma resposta';

  @override
  String get sessionSpeedText1 => 'Que rapidez!';

  @override
  String get sessionSpeedText2 => 'Você quebrou o cronômetro.';

  @override
  String get sessionSpeedText3 => 'Na velocidade da luz.';

  @override
  String get sessionSpeedText4 => 'Reflexos de aço.';

  @override
  String get sessionSpeedText5 => 'Ninguém te alcança hoje.';

  @override
  String get sessionSpeedText6 => 'Tempo recorde!';

  @override
  String get sessionSpeedText7 => 'Velocidade supersônica.';

  @override
  String get sessionStandardText1 => 'Lição concluída!';

  @override
  String get sessionStandardText2 => 'Um passo mais perto do seu objetivo.';

  @override
  String get sessionStandardText3 => 'O progresso é o caminho.';

  @override
  String get sessionStandardText4 => 'Bom trabalho constante.';

  @override
  String get sessionStandardText5 => 'Continue assim, somando dias.';

  @override
  String get sessionStandardText6 => 'Consistência acima de tudo.';

  @override
  String get sessionStandardText7 => 'Disciplina traz resultados.';

  @override
  String get sessionStartQuiz => 'INICIAR QUIZ';

  @override
  String get sessionSummaryAccuracy => 'PRECISÃO';

  @override
  String get sessionSummaryAccuracy1 => 'Sua precisão é extraordinária!';

  @override
  String get sessionSummaryAccuracy2 => 'Excelente pontaria!';

  @override
  String get sessionSummaryAccuracy3 => 'Bom progresso!';

  @override
  String get sessionSummaryAccuracy4 => 'Você está melhorando!';

  @override
  String get sessionSummaryAccuracy5 => 'Ótimo esforço!';

  @override
  String get sessionSummaryAccuracy6 => 'Continue aprendendo!';

  @override
  String get sessionSummaryAccuracy7 => 'Cada pergunta conta!';

  @override
  String get sessionSummaryExp => 'EXP';

  @override
  String get sessionSummaryGems => 'GEMAS';

  @override
  String get sessionSummaryReceiveReward => 'RECEBER RECOMPENSA';

  @override
  String get sessionSummaryReceiveRewardLabel => 'Receber recompensa';

  @override
  String get sessionSummarySpeed1 => 'Velocidade relâmpago!';

  @override
  String get sessionSummarySpeed2 => 'Reflexo rápido!';

  @override
  String get sessionSummarySpeed3 => 'Aprendiz rápido!';

  @override
  String get sessionSummarySpeed4 => 'Bom ritmo!';

  @override
  String get sessionSummarySpeed5 => 'No caminho certo!';

  @override
  String get sessionSummarySpeed6 => 'Ganhou impulso!';

  @override
  String get sessionSummarySpeed7 => 'Progresso constante!';

  @override
  String get sessionSummaryStandard1 => 'Lição concluída!';

  @override
  String get sessionSummaryStandard2 => 'Muito bem!';

  @override
  String get sessionSummaryStandard3 => 'Bom trabalho!';

  @override
  String get sessionSummaryStandard4 => 'Legal!';

  @override
  String get sessionSummaryStandard5 => 'Você conseguiu!';

  @override
  String get sessionSummaryStandard6 => 'Mais um passo à frente!';

  @override
  String get sessionSummaryStandard7 => 'Continue!';

  @override
  String get sessionSummaryTime => 'TEMPO';

  @override
  String get sessionTime => 'TEMPO';

  @override
  String get settingsAmoledDark => 'AMOLED Escuro';

  @override
  String get settingsAmoledDarkSubtitle =>
      'Fundo puro #000000 para economizar bateria';

  @override
  String get settingsAnalytics => 'Análises anônimas';

  @override
  String get settingsAnalyticsDesc =>
      'Ajude a melhorar o Sagen com dados de uso anônimos';

  @override
  String get settingsDeleteAccount => 'Excluir conta';

  @override
  String get settingsDeleteAccountConfirm =>
      'Tem certeza? Esta ação não pode ser desfeita.';

  @override
  String get settingsExportData => 'Exportar dados';

  @override
  String get settingsFontSize => 'Tamanho da fonte';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLogout => 'Sair';

  @override
  String get settingsLogoutConfirm => 'Tem certeza que deseja sair?';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsReduceAnimations => 'Reduzir animações';

  @override
  String get settingsSound => 'Som';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsVibration => 'Vibração';

  @override
  String get shareProfile => 'Compartilhar cartão de perfil';

  @override
  String get shareRanking => 'Compartilhar ranking';

  @override
  String get sharing => 'Compartilhando...';

  @override
  String get shieldTierBasic => 'Escudo Básico';

  @override
  String get shieldTierCrystal => 'Escudo de Cristal';

  @override
  String get shieldTierGlow => 'Escudo Radiante';

  @override
  String get shieldTierInactive => 'Sem Escudo';

  @override
  String get shieldTierLegendary => 'Escudo Lendário';

  @override
  String get shieldTierParticles => 'Escudo de Partículas';

  @override
  String get shopBgCyber => 'Fundo Cyberpunk';

  @override
  String get shopBgCyberDesc => 'Fundo de perfil futurista';

  @override
  String get shopBgMatrix => 'Fundo Matrix';

  @override
  String get shopBgMatrixDesc => 'Fundo matrix verde';

  @override
  String get shopFrameDiamond => 'Moldura Diamante';

  @override
  String get shopFrameDiamondDesc => 'Moldura exclusiva diamante';

  @override
  String get shopFrameNeon => 'Moldura Neon';

  @override
  String get shopFrameNeonDesc => 'Moldura de perfil neon';

  @override
  String get shopItemAcquired => 'Adquirido';

  @override
  String get shopItemOwned => 'Obtido';

  @override
  String get shopOwned => 'Possuído';

  @override
  String get shopSageGolden => 'Sage Dourado';

  @override
  String get shopSageGoldenDesc => 'Skin dourada exclusiva';

  @override
  String get shopSageNeon => 'Sage Neon';

  @override
  String get shopSageNeonDesc => 'Skin ciano neon para Sage';

  @override
  String get shopSageShadow => 'Sage Sombra';

  @override
  String get shopSageShadowDesc => 'Skin escura para Sage';

  @override
  String get shopTitleGuardian => 'Título Guardião Digital';

  @override
  String get shopTitleGuardianDesc => 'Título de protetor';

  @override
  String get shopTitleHacker => 'Título Hacker Ético';

  @override
  String get shopTitleHackerDesc => 'Título especial no perfil';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get skipText => 'Pular';

  @override
  String get skipToContent => 'Pular para o conteúdo principal';

  @override
  String get sounds => 'Sons';

  @override
  String get soundsSubtitle => 'Efeitos sonoros do aplicativo';

  @override
  String get spanish => 'Espanhol';

  @override
  String get speedSort2fa => 'Autenticação em dois fatores';

  @override
  String get speedSortAntivirus => 'Antivírus';

  @override
  String get speedSortDataEncryption => 'Criptografia de dados';

  @override
  String get speedSortFakeEmail => 'E-mail falso';

  @override
  String get speedSortFirewall => 'Firewall';

  @override
  String get speedSortFraudulentCall => 'Chamada fraudulenta';

  @override
  String get speedSortProtectionCategory => 'Proteção';

  @override
  String get speedSortScamCategory => 'Golpe';

  @override
  String get speedSortSecurityCategory => 'Segurança';

  @override
  String get speedSortSmsLink => 'Link SMS';

  @override
  String get speedSortStrongPassword => 'Senha forte';

  @override
  String get speedSortVpn => 'VPN';

  @override
  String get splashTitle => 'SAGEN';

  @override
  String get stage1Subtitle => 'Conceitos básicos de segurança digital';

  @override
  String get stage1Title => 'Fundamentos';

  @override
  String get stage2Subtitle => 'Identifique tentativas de engano';

  @override
  String get stage2Title => 'Phishing';

  @override
  String get stage3Subtitle => 'Crie chaves seguras e proteja-se';

  @override
  String get stage3Title => 'Senhas';

  @override
  String get stage4Subtitle => 'Proteja sua privacidade nas plataformas';

  @override
  String get stage4Title => 'Redes Sociais';

  @override
  String get stage5Subtitle => 'Desinformação e sites confiáveis';

  @override
  String get stage5Title => 'Navegação Segura';

  @override
  String get stage6Subtitle => 'Controle seus dados pessoais';

  @override
  String get stage6Title => 'Privacidade Digital';

  @override
  String get stage7Subtitle => 'Proteção total para especialistas';

  @override
  String get stage7Title => 'Cibersegurança Avançada';

  @override
  String get stage8Subtitle => 'Torne-se um guardião digital';

  @override
  String get stage8Title => 'Especialista Digital';

  @override
  String stageProgress(Object percent) {
    return 'Progresso da etapa: $percent por cento';
  }

  @override
  String get startText => 'Começar';

  @override
  String get statsExcellent => 'Excelente!';

  @override
  String get statsIncredible => 'Incrível!';

  @override
  String get statsKeepTrying => 'Continue tentando.';

  @override
  String get statsNoData => 'Nenhum dado de lição';

  @override
  String get statsNoErrors => 'Sem erros!';

  @override
  String get statsReceiveXp => 'RECEBER XP';

  @override
  String get statsSpeed => 'Velocidade';

  @override
  String get statsStartStage1 => 'Você começará pela Etapa 1, Aula 1';

  @override
  String get statsStartStage2 => 'Você começará pela Etapa 2, Aula 1';

  @override
  String get statsWellDone => 'Muito bem!';

  @override
  String get statusCompleted => 'concluída';

  @override
  String get storeAdEarnXp => 'Ganhe XP assistindo';

  @override
  String get storeAdRewardMessage => '+1 Doação por assistir ao anúncio';

  @override
  String get storeAdWatchVideo => 'Assista a um vídeo de 30 segundos';

  @override
  String storeBuyItem(Object cost, Object item) {
    return 'Comprar $item por $cost doações';
  }

  @override
  String get storeCategoryConsumables => 'Consumíveis';

  @override
  String get storeCategoryCosmetics => 'Cosméticos';

  @override
  String get storeCategoryThemes => 'Temas';

  @override
  String get storeChestAvailable => 'Baú Diário Disponível!';

  @override
  String get storeChestComeBack => 'Volte amanhã';

  @override
  String storeChestExpiresIn(Object gems) {
    return '$gems doados — expira à meia-noite';
  }

  @override
  String get storeChestRenews => 'Seu baú renova a cada dia';

  @override
  String get storeClaimError =>
      'Falha ao resgatar recompensa. Tente novamente.';

  @override
  String storeConfirmMessage(Object cost, Object item) {
    return 'Deseja comprar $item por $cost doações?';
  }

  @override
  String get storeConfirmTitle => 'Confirmar compra';

  @override
  String get storeDonate => 'Doar';

  @override
  String storeDonateSubtitle(Object price) {
    return 'A partir de $price';
  }

  @override
  String get storeDonationsLabel => 'doações';

  @override
  String get storeGemTipAchievement =>
      'Conquistas: gemas baseadas na dificuldade';

  @override
  String get storeGemTipChest => 'Abra baús: gemas baseadas no tipo de baú';

  @override
  String get storeGemTipFirstLesson => 'Primeira lição do dia: +10 gemas';

  @override
  String get storeGemTipLesson =>
      'Complete lições: 5 gemas por resposta correta';

  @override
  String get storeGemTipMission => 'Missões diárias: +12 gemas';

  @override
  String get storeGemTipPerfect => 'Lição perfeita: +20 gemas extras';

  @override
  String get storeGemTipStreak => 'Sequências: até +150 gemas';

  @override
  String get storeHowToEarnGems => 'Como ganhar gemas?';

  @override
  String get storeNoItems => 'Nenhum item disponível no momento.';

  @override
  String get storeOpen => 'Abrir';

  @override
  String get storePersonalization => 'Personalização';

  @override
  String get storeProtectStreak => 'Proteja sua sequência';

  @override
  String get storeDailyChestClaim => 'Reivindicar';

  @override
  String storeDailyChestReward(Object xp) {
    return '+$xp XP!';
  }

  @override
  String get storeDailyChestSubtitle =>
      'Resgate sua recompensa diária gratuita';

  @override
  String get storeDailyChestTitle => 'Baú diário';

  @override
  String get storePurchaseFailed =>
      'Falha na validação da compra. Tente novamente.';

  @override
  String storeNeedMoreGems(Object have, Object need, Object needed) {
    return 'Você precisa de mais $needed gemas ($have/$need)';
  }

  @override
  String get storePurchaseSuccess => 'Compra realizada com sucesso!';

  @override
  String get storeAlreadyOwned => 'Você já possui este item.';

  @override
  String get storeShieldLimitReached => 'Limite de escudos atingido';

  @override
  String get storeSupport => 'Apoie-nos';

  @override
  String get storeSupportTiers => 'Níveis de apoio';

  @override
  String get storeThankYou => 'Obrigado pelo seu apoio!';

  @override
  String get storeTitle => 'Loja';

  @override
  String get storeWatch => 'Assistir';

  @override
  String storeWhatsappPackages(Object price) {
    return 'Pacotes a partir de $price — Pagamento via WhatsApp';
  }

  @override
  String get streakAchievements => 'Conquistas e medalhas pela consistência';

  @override
  String get streakBadge => 'SEQUÊNCIA';

  @override
  String get streakChest100Message => '100 dias. Lenda.';

  @override
  String get streakChest100Title => 'Sequência de 100 dias!';

  @override
  String get streakChest14Message =>
      'Duas semanas de consistência. Continue assim!';

  @override
  String get streakChest14Title => 'Sequência de 14 dias!';

  @override
  String get streakChest30Message => 'Um mês. Você é um Guardião Digital.';

  @override
  String get streakChest30Title => 'Sequência de 30 dias!';

  @override
  String get streakChest7Message =>
      'Uma semana protegendo sua identidade digital.';

  @override
  String get streakChest7Title => 'Sequência de 7 dias!';

  @override
  String get streakCommitButton => 'MANTER MEU COMPROMISSO';

  @override
  String get streakCurrent => 'Sequência atual';

  @override
  String streakCurrentProgress(Object goal, Object current) {
    return 'Sequência atual: $current / $goal dias';
  }

  @override
  String get streakDayFri => 'S';

  @override
  String get streakDayLabel => 'dia de sequência';

  @override
  String get streakDayMon => 'S';

  @override
  String get streakDayOfStreak => 'dia de sequência';

  @override
  String get streakDaySat => 'S';

  @override
  String get streakDaySun => 'D';

  @override
  String get streakDayThu => 'Q';

  @override
  String get streakDayTue => 'T';

  @override
  String get streakDayWed => 'Q';

  @override
  String streakDays(Object count) {
    return '$count dias';
  }

  @override
  String streakDaysCount(Object count) {
    return 'Sequência de $count dias';
  }

  @override
  String streakDaysCountPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# dias de sequência',
      one: '# dia de sequência',
    );
    return '$_temp0';
  }

  @override
  String get streakEmotional100 => '100 dias de proteção constante. Lenda.';

  @override
  String get streakEmotional14 =>
      'Duas semanas de consistência. Seu escudo brilha.';

  @override
  String get streakEmotional3 =>
      '3 dias seguidos. Você está construindo um hábito sólido.';

  @override
  String get streakEmotional30 =>
      'Um mês de aprendizado. Sua dedicação te faz um Guardião Digital.';

  @override
  String get streakEmotional50 => '50 dias de proteção digital constante.';

  @override
  String get streakEmotional7 =>
      'Uma semana protegendo sua identidade digital. Continue assim!';

  @override
  String get streakFireCard => 'Cartão de sequência em chamas';

  @override
  String get streakFireCardA11y => 'Cartão de sequência de fogo';

  @override
  String get streakFireCardLabel => 'Sequência de Fogo';

  @override
  String get streakFreeze => 'Protetor de sequência';

  @override
  String get streakFreezeDescription =>
      'Mantenha sua sequência quando perder um dia';

  @override
  String get streakFreezeUsed => 'Um congelamento protegeu sua sequência.';

  @override
  String get streakFrozen => 'Sequência congelada';

  @override
  String get streakGotIt => 'ENTENDI';

  @override
  String get streakKeepAlive => 'Mantenha sua sequência viva!';

  @override
  String get streakKeepAliveDesc =>
      'Conclua uma lição a cada dia para manter sua sequência.\nCada dia conta para fortalecer seu escudo digital.';

  @override
  String get streakKeepCommitment => 'MANTER MEU COMPROMISSO';

  @override
  String get streakLongest => 'Melhor sequência';

  @override
  String get streakMessage100Days => '100 dias. Lenda.';

  @override
  String get streakMessage14Days => 'Duas semanas. Seu escudo brilha.';

  @override
  String get streakMessage30Days => 'Um mês. Você é um Guardião Digital.';

  @override
  String get streakMessage3Days => '3 dias. Bom começo.';

  @override
  String get streakMessage50Days => '50 dias de proteção constante.';

  @override
  String get streakMessage7Days => 'Uma semana! Continue assim.';

  @override
  String get streakMessageActive =>
      'Sequência ativa! A consistência é sua melhor arma hoje.';

  @override
  String get streakMessageAtRisk => 'Sua sequência está em risco!';

  @override
  String get streakMessageCloser =>
      'Um dia mais, um passo mais perto do seu objetivo.';

  @override
  String get streakMessageEachDay =>
      'Cada dia conta. Seu compromisso te torna mais forte.';

  @override
  String get streakMessageKeepGoing =>
      'Continue assim! A disciplina de hoje é a vitória de amanhã.';

  @override
  String get streakMessageKeepProtecting => 'Continue se protegendo!';

  @override
  String get streakMessageNew =>
      'Uma nova sequência! Pratique todos os dias e ajude-a a crescer.';

  @override
  String get streakMessageStartActivities =>
      'Complete atividades para iniciar sua sequência.';

  @override
  String get streakMsg1 =>
      'Uma nova sequência! Pratique todos os dias e ajude-a a crescer.';

  @override
  String get streakMsg2 =>
      'Sequência ativa! Consistência é sua melhor arma hoje.';

  @override
  String get streakMsg3 => 'Cada dia conta. Seu compromisso te fortalece.';

  @override
  String get streakMsg4 =>
      'Continue assim! A disciplina de hoje é a vitória de amanhã.';

  @override
  String get streakMsg5 => 'Mais um dia, um passo mais perto do seu objetivo.';

  @override
  String get streakNoActiveStreak => 'Nenhuma sequência ativa';

  @override
  String get streakReminder => 'Lembretes de Sequência';

  @override
  String get streakReminderSubtitle =>
      'Receba lembretes para manter sua sequência';

  @override
  String get streakRewards => 'Recompensas exclusivas ao atingir metas';

  @override
  String get streakShieldActive =>
      'Escudo ativo — sua sequência está protegida hoje!';

  @override
  String get streakShieldOnboarding =>
      'Compre um escudo para proteger sua sequência se perder um dia.';

  @override
  String get streakStrongerShield => 'Um escudo mais forte a cada dia';

  @override
  String get streakTitle => 'Minha Sequência';

  @override
  String get streakTitleShort => 'Sequência';

  @override
  String get summarizeButton => 'Resumo rápido';

  @override
  String get summaryCommitment => 'Compromisso';

  @override
  String get summaryDailyGoal => 'Meta diária';

  @override
  String get summaryGoodWork => 'Bom trabalho!';

  @override
  String get summaryInterest => 'Interesse';

  @override
  String get summaryKeepPracticing => 'Continue praticando';

  @override
  String get summaryKnowledge => 'Conhecimento';

  @override
  String get summaryLearning => 'Aprendizado';

  @override
  String get summaryMotivations => 'Motivações';

  @override
  String get summaryOrigin => 'Origem';

  @override
  String get summaryPerfect => 'Perfeito!';

  @override
  String get summaryReady =>
      'Tudo pronto para começar sua jornada de segurança digital.';

  @override
  String summaryStreakDays(Object days) {
    return '+$days dia(s)';
  }

  @override
  String get summaryXpBonus => 'Bônus XP';

  @override
  String get summaryXpEarned => 'XP ganho';

  @override
  String get supporterBadge => 'Supporter';

  @override
  String get syncSnackbar => 'Progresso sincronizado';

  @override
  String get syncStatus => 'Status da Sincronização';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get termsConditions => 'Termos e Condições';

  @override
  String get thankYouForSupport => 'Obrigado pelo seu apoio!';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeDarkLabel => 'Escuro';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeLightLabel => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeSystemLabel => 'Sistema';

  @override
  String get themeTitle => 'Aparência';

  @override
  String get tierBasic => 'Básico';

  @override
  String get tierCrystal => 'Cristal';

  @override
  String get tierGlow => 'Brilho';

  @override
  String get tierInactive => 'Inativo';

  @override
  String get tierLegendary => 'Lendário';

  @override
  String get tierParticles => 'Partículas';

  @override
  String get totalProgress => 'Progresso total';

  @override
  String get tryAgain => 'Conecte-se e tente novamente.';

  @override
  String tutorLessonsProgress(Object completed, Object required) {
    return '$completed / $required lições';
  }

  @override
  String get tutorLocked => 'Tutor IA Bloqueado';

  @override
  String get tutorLockedDescription =>
      'Conclua pelo menos 10 lições para desbloquear o Sage, seu tutor pessoal de cibersegurança.';

  @override
  String tutorMotivationAlmost(Object count) {
    return 'Quase lá, faltam apenas $count lições. Continue!';
  }

  @override
  String get tutorMotivationGeneral =>
      'Cada lição te aproxima do seu tutor pessoal de cibersegurança.';

  @override
  String tutorMotivationGood(Object count) {
    return 'Bom ritmo! Você precisa de mais $count lições para acessar o Sage.';
  }

  @override
  String get tutorSampleAnswer1 =>
      'Nunca compartilhe sua senha. Use um gerenciador de senhas e ative a autenticação de dois fatores.';

  @override
  String get tutorSampleQuestion1 =>
      'O que devo fazer se receber um e-mail suspeito?';

  @override
  String get tutorSampleQuestion2 => 'Como posso criar uma senha forte?';

  @override
  String get tutorSampleTitle => 'Conversa de exemplo';

  @override
  String get tutorTitle => 'Tutor IA';

  @override
  String get tutorialNext => 'Próximo';

  @override
  String get tutorialSkip => 'Pular';

  @override
  String get tutorialStart => 'Vamos lá!';

  @override
  String get tutorialStep1 => 'Olá! Sou o Sage, seu guia de cibersegurança.';

  @override
  String get tutorialStep2 =>
      'Conclua lições para ganhar doações e subir de nível.';

  @override
  String get tutorialStep3 =>
      'Mantenha sua sequência diária para desbloquear baús especiais.';

  @override
  String get tutorialStep4 =>
      'Sua missão: proteger sua identidade digital. Vamos aprender juntos!';

  @override
  String get unknownLabel => 'Desconhecido';

  @override
  String get updateChangelog => 'Atualizações e novidades';

  @override
  String get updateChangelogDesc =>
      'Nova tela na barra inferior mostrando o histórico de alterações e novidades do app.';

  @override
  String get updateChestSystem => 'Baús de sequência e lição';

  @override
  String get updateChestSystemDesc =>
      'Novo sistema de baús: baú diário para sequência, baú de lição a cada 3/5/6/10 lições concluídas.';

  @override
  String get updateDailyMissions => 'Missões diárias';

  @override
  String get updateDailyMissionsDesc =>
      'Sistema de missões diárias com recompensas em doações e experiência.';

  @override
  String get updateEnergySystem => 'Sistema de Energia';

  @override
  String get updateEnergySystemDesc =>
      'Agora cada lição usa energia. Responda corretamente para gastar apenas 1, falhar custa 2. Combos de acertos regeneram energia. Ao chegar a 0 não pode continuar.';

  @override
  String get updateFirstVersion => 'Primeira versão';

  @override
  String get updateFirstVersionDesc =>
      'Lançamento inicial com lições interativas, sequência diária, doações, loja e perfil do usuário.';

  @override
  String get updateImprovedIcons => 'Ícones de itens melhorados';

  @override
  String get updateImprovedIconsDesc =>
      'Todos os itens especiais agora têm ícones personalizados e mais chamativos na loja e inventário.';

  @override
  String get updateInfiniteEnergy => 'Energia Infinita';

  @override
  String get updateInfiniteEnergyDesc =>
      'Novo item especial na loja que concede energia ilimitada por tempo limitado. Ative pelo seu inventário.';

  @override
  String get updateLessonBoosters => 'Potenciadores de lição';

  @override
  String get updateLessonBoostersDesc =>
      'Novos itens: Boost de XP (2x), Multiplicador de XP (2x nos baús), Boost de Sorte (2x chances). Compre e ative na loja.';

  @override
  String get updateMercadoPago => 'Mercado Pago integrado';

  @override
  String get updateMercadoPagoDesc =>
      'Pagamentos diretos com Mercado Pago para pacotes de doações e bundles. Pagamento por WhatsApp também disponível.';

  @override
  String get updateNew => 'NOVO';

  @override
  String get updateProgrammaticMascot => 'Mascote programático';

  @override
  String get updateProgrammaticMascotDesc =>
      'O mascote agora é desenhado com CustomPainter. 29 emoções, sem assets, transições suaves entre emoções.';

  @override
  String get updateStreakProtectorImproved => 'Protetor de sequência melhorado';

  @override
  String get updateStreakProtectorImprovedDesc =>
      'Limite máximo de 2 protetores. Ao atingir, ofertas de potenciadores são exibidas.';

  @override
  String get updateTestFix => 'Correção de testes unitários';

  @override
  String get updateTestFixDesc =>
      '7 testes com falha corrigidos. Todos os testes passam agora (419 testes). 0 problemas de análise.';

  @override
  String get updateTypeFeature => 'NOVA FUNÇÃO';

  @override
  String get updateTypeFix => 'CORREÇÃO';

  @override
  String get updateTypeImprovement => 'MELHORIA';

  @override
  String get updateTypedRoutes => 'Rotas tipadas com GoRouter Builder';

  @override
  String get updateTypedRoutesDesc =>
      'As rotas de splash e welcome agora são tipadas, detectando erros em tempo de compilação.';

  @override
  String get updates => 'Atualizações';

  @override
  String get updatesTitle => 'Atualizações e novidades';

  @override
  String get verifyEmailCheckButton => 'Já verifiquei';

  @override
  String verifyEmailMessage(Object email) {
    return 'Enviamos um link de verificação para $email. Clique no link para ativar sua conta.';
  }

  @override
  String get verifyEmailNotVerified =>
      'Seu e-mail ainda não foi verificado. Verifique sua caixa de entrada.';

  @override
  String get verifyEmailResendButton => 'Reenviar e-mail de verificação';

  @override
  String get verifyEmailResendError =>
      'Não foi possível reenviar o e-mail. Tente novamente.';

  @override
  String get verifyEmailSent =>
      'E-mail de verificação enviado. Verifique sua caixa de entrada.';

  @override
  String get verifyEmailSignOut => 'Sair da conta';

  @override
  String get verifyEmailSuccess => 'E-mail verificado! Bem-vindo ao SAGEN.';

  @override
  String get verifyEmailTitle => 'Verifique seu e-mail';

  @override
  String get viewAchievements => 'Ver conquistas';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get weeklyChestComplete => 'Baú semanal ganho!';

  @override
  String get weeklyChestDesc => 'Conclua 5 missões diárias para um baú épico';

  @override
  String get weeklyChestProgress => 'Progresso do Baú Semanal';

  @override
  String weeklyChestProgressCount(Object done, Object total) {
    return '$done/$total';
  }

  @override
  String get welcomeLoginButton => 'JÁ TENHO UMA CONTA';

  @override
  String get welcomeStartButton => 'COMEÇAR AGORA';

  @override
  String get welcomeSubtitle =>
      'Análise inteligente e segurança digital.\nGratuito para sempre.';

  @override
  String get wizardAllAbove => 'Tudo isso';

  @override
  String get wizardAppStore => 'App Store';

  @override
  String get wizardArticles => 'Ler artigos';

  @override
  String get wizardBoostStudies => 'Impulsionar meus estudos';

  @override
  String get wizardChatSage => 'Conversar com Sage';

  @override
  String get wizardCommit14 => '14 dias';

  @override
  String get wizardCommit14Sub => '80 doações';

  @override
  String get wizardCommit30 => '30 dias';

  @override
  String get wizardCommit30Sub => '200 doações';

  @override
  String get wizardCommit50 => '50 dias';

  @override
  String get wizardCommit50Sub => '400 doações';

  @override
  String get wizardCommit7 => '7 dias';

  @override
  String get wizardCommit7Sub => '30 doações';

  @override
  String get wizardCommitment => 'Escolha seu compromisso';

  @override
  String get wizardCommitmentSage => 'Selecione suas metas de consistência';

  @override
  String get wizardConfirmed => 'Compromisso confirmado';

  @override
  String get wizardConfirmedSage =>
      'Você configurou seu caminho de aprendizado!';

  @override
  String get wizardCuriosity => 'Curiosidade';

  @override
  String get wizardDetectScams => 'Detectar golpes';

  @override
  String get wizardFacebook => 'Facebook';

  @override
  String get wizardFriends => 'Amigos';

  @override
  String get wizardGoal10 => '10 min';

  @override
  String get wizardGoal10Sub => 'Normal';

  @override
  String get wizardGoal15 => '15 min';

  @override
  String get wizardGoal15Sub => 'Sério';

  @override
  String get wizardGoal3 => '3 min';

  @override
  String get wizardGoal30 => '30 min';

  @override
  String get wizardGoal30Sub => 'Intenso';

  @override
  String get wizardGoal3Sub => 'Tranquilo';

  @override
  String get wizardGoogle => 'Google';

  @override
  String get wizardHaveFun => 'Me divertir';

  @override
  String get wizardHowDidYouFind => 'Como você conheceu o SAGEN?';

  @override
  String get wizardHowDidYouFindSage => 'Diga-me, como você nos encontrou?';

  @override
  String get wizardHowFound => 'Como você encontrou o SAGEN?';

  @override
  String get wizardHowFoundSage => 'Me conta, como nos encontrou?';

  @override
  String get wizardHowMuchKnow => 'Quanto você sabe sobre segurança digital?';

  @override
  String get wizardHowMuchKnowSage => 'Quanto você sabe sobre o assunto?';

  @override
  String get wizardHowMuchSage => 'Quanto você sabe sobre o assunto?';

  @override
  String get wizardHowMuchYouKnow =>
      'Quanto você sabe sobre segurança digital?';

  @override
  String get wizardHowPrefer => 'Como você prefere aprender?';

  @override
  String get wizardHowPreferSage => 'Escolha suas formas favoritas de aprender';

  @override
  String get wizardInstagram => 'Instagram';

  @override
  String get wizardLevel1 => 'Estou começando';

  @override
  String get wizardLevel1Sub => 'Nunca explorei este tópico';

  @override
  String get wizardLevel2 => 'Conheço alguns conceitos';

  @override
  String get wizardLevel2Sub => 'Reconheço alguns termos';

  @override
  String get wizardLevel3 => 'Posso me defender';

  @override
  String get wizardLevel3Sub => 'Entendo e pratico o básico';

  @override
  String get wizardLevel4 => 'Entendo vários tópicos';

  @override
  String get wizardLevel4Sub => 'Domino vários conceitos';

  @override
  String get wizardLevel5 => 'Sei bastante sobre o assunto';

  @override
  String get wizardLevel5Sub => 'Posso debater tópicos avançados';

  @override
  String get wizardLinks => 'Analisar links';

  @override
  String get wizardNews => 'Notícias';

  @override
  String get wizardOther => 'Outro';

  @override
  String get wizardPrepareWork => 'Me preparar para o trabalho';

  @override
  String get wizardProtect => 'Me proteger';

  @override
  String get wizardProtectAccounts => 'Proteger minhas contas';

  @override
  String get wizardProtectFamily => 'Proteger minha família';

  @override
  String get wizardProtectPrivacy => 'Proteger minha privacidade';

  @override
  String get wizardQuizzes => 'Praticar com quizzes';

  @override
  String get wizardSafeBrowsing => 'Navegar com segurança';

  @override
  String get wizardTV => 'TV';

  @override
  String get wizardTikTok => 'TikTok';

  @override
  String get wizardTimeDedicate => 'Quanto tempo pode dedicar por dia?';

  @override
  String get wizardTimeSage => 'Escolha seu ritmo de aprendizado ideal';

  @override
  String get wizardVideos => 'Assistir vídeos educativos';

  @override
  String get wizardWelcome => 'Bem-vindo ao SAGEN!';

  @override
  String get wizardWelcomeSage =>
      'Olá! Sou o Sage, seu guia de segurança digital. Vamos começar?';

  @override
  String get wizardWelcomeTitle => 'Bem-vindo ao SAGEN!';

  @override
  String get wizardWhatLearn => 'O que você gostaria de aprender?';

  @override
  String get wizardWhatLearnSage => 'O que você gostaria de aprender primeiro?';

  @override
  String get wizardWhyLearn => 'Por que você quer aprender?';

  @override
  String get wizardWhyLearnSage =>
      'Por que você quer aprender segurança digital?';

  @override
  String get wizardYouTube => 'YouTube';

  @override
  String get xpBoostLabel => 'x2 Boost de XP';

  @override
  String get xpLevelUp => 'Subir de nível!';

  @override
  String xpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String xpRewardLabel(Object gems) {
    return '+$gems XP';
  }

  @override
  String get yourActivity => 'Sua atividade';

  @override
  String get yourLearning => 'Seu aprendizado';

  @override
  String get xpLabel => 'XP';

  @override
  String get xpMultiplier => 'x2 XP';

  @override
  String get chatTypingIndicator => 'Sage está digitando...';

  @override
  String get demoModeOffline => 'MODO DEMO — Offline';

  @override
  String get errorSync => 'Erro de sincronização';

  @override
  String shareChestText(Object items, Object type) {
    return 'Recebi $items de um baú $type no SAGEN!';
  }

  @override
  String get paymentMethodsLocal => 'WhatsApp / Yape / Plin';

  @override
  String get paymentMethodsMercadoPago => 'Mercado Pago';

  @override
  String get streakFlame => 'Chama de sequência';

  @override
  String treasureChest(Object type) {
    return 'Baú do tesouro $type';
  }

  @override
  String get errorRestart => 'Reiniciar';

  @override
  String get chatEmptyDesc =>
      'Pergunte sobre cibersegurança ou escolha uma sugestão rápida.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get shareButton => 'Compartilhar';

  @override
  String get tapToContinue => 'Toque para continuar';

  @override
  String get paymentSuccessful => 'Pagamento bem-sucedido';

  @override
  String get errorLoadingQuestions => 'Erro ao carregar perguntas.';

  @override
  String get errorGenericShort => 'Erro';

  @override
  String quizTimeRemaining(Object time) {
    return 'Tempo restante: $time';
  }

  @override
  String get quizVerdictCorrect => 'Resposta correta';

  @override
  String get quizVerdictIncorrect => 'Resposta incorreta';

  @override
  String get exitQuizTitle => 'Tem certeza de que deseja sair da lição?';

  @override
  String get exitQuizContent =>
      'Tem certeza de que deseja sair do questionário?';

  @override
  String currentStreakDays(Object count) {
    return 'Sequência atual: $count dias';
  }

  @override
  String get activityMap30Days => 'Mapa de atividade dos últimos 30 dias';

  @override
  String courseProgressLabel(Object percent) {
    return 'Progresso total do curso: $percent%';
  }

  @override
  String stageProgressLabel(Object percent) {
    return 'Progresso da etapa: $percent%';
  }

  @override
  String collapseSession(Object title) {
    return 'Recolher sessão: $title';
  }

  @override
  String expandSession(Object title) {
    return 'Expandir sessão: $title';
  }

  @override
  String xpGainedLabel(Object xp) {
    return '+$xp XP ganhos';
  }

  @override
  String accuracyPercentLabel(Object percent) {
    return 'Precisão: $percent%';
  }

  @override
  String timeLabel(Object time) {
    return 'Tempo: $time';
  }

  @override
  String livesRemainingLabel(Object count) {
    return 'Vidas restantes: $count de 3';
  }

  @override
  String get miniGameExitTitle => 'Sair do jogo?';

  @override
  String get miniGameExitContent =>
      'Você perderá o progresso atual. Tem certeza?';

  @override
  String get paymentCancelTitle => 'Cancelar pagamento';

  @override
  String get paymentCancelContent =>
      'Tem certeza de que deseja cancelar? O progresso será perdido.';

  @override
  String resultXpGained(Object xp) {
    return '$xp ganhos';
  }

  @override
  String resultAccuracyLabel(Object percent) {
    return 'Precisão: $percent%';
  }

  @override
  String resultLivesLabel(Object count) {
    return 'Vidas: $count';
  }

  @override
  String get storeNewChestHint => 'Novo cofre disponível';

  @override
  String get profilePhoto => 'Foto do perfil';

  @override
  String gemBalanceLabel(Object count) {
    return 'Saldo de gemas: $count';
  }

  @override
  String wizardStepLabel(Object step) {
    return 'Etapa $step';
  }

  @override
  String chestRewardShareText(Object items, Object type) {
    return 'Recebi $items de um baú $type no SAGEN!';
  }

  @override
  String get gemRainAnimationLabel => 'Animação de chuva de gemas';

  @override
  String get exitQuizLabel => 'Sair do questionário';

  @override
  String get shopItemFocusElixirName => 'Elixir de Foco';

  @override
  String get shopItemFocusElixirDesc => '2x EXP por 15 minutos';

  @override
  String get shopItemXpBoostName => 'Impulso de XP';

  @override
  String get shopItemXpBoostDesc => '2x XP na sua próxima lição';

  @override
  String get shopItemLuckBoostName => 'Impulso de Sorte';

  @override
  String get shopItemLuckBoostDesc => '+15% de raridade de baús por 30 min';

  @override
  String get shopItemSageMonocleName => 'Monóculo do Sage';

  @override
  String get shopItemSageMonocleDesc => 'Elimina 2 respostas incorretas';

  @override
  String get shopItemTimeWarpName => 'Distorção Temporal';

  @override
  String get shopItemTimeWarpDesc =>
      'Pula o tempo de recarga na próxima revisão';

  @override
  String get shopItemTitaniumShieldName => 'Escudo de Titânio';

  @override
  String get shopItemTitaniumShieldDesc =>
      'Protege sua sequência se perder 1 dia';

  @override
  String get shopItemPhoenixFeatherName => 'Pena de Fênix';

  @override
  String get shopItemPhoenixFeatherDesc =>
      'Revive sua sequência se for perdida';

  @override
  String get shopItemNeonFrameName => 'Moldura Neon';

  @override
  String get shopItemNeonFrameDesc => 'Moldura animada com brilho neon';

  @override
  String get shopItemGalaxyFrameName => 'Moldura Galáxia';

  @override
  String get shopItemGalaxyFrameDesc => 'Moldura estelar galáctica';

  @override
  String get shopItemDragonFrameName => 'Moldura Dragão';

  @override
  String get shopItemDragonFrameDesc => 'Moldura de fogo de dragão animada';

  @override
  String get shopItemCrystalFrameName => 'Moldura Cristal';

  @override
  String get shopItemCrystalFrameDesc => 'Moldura de gelo cristalino';

  @override
  String get shopItemSkullFrameName => 'Moldura Caveira';

  @override
  String get shopItemSkullFrameDesc => 'Moldura de chama de caveira lendária';

  @override
  String get shopItemTitleStormBreakerName => 'Título: Quebra-Tempestade';

  @override
  String get shopItemTitleStormBreakerDesc => 'Título raro para seu perfil';

  @override
  String get shopItemTitleCyberSageName => 'Título: Sage Cibernético';

  @override
  String get shopItemTitleCyberSageDesc => 'Título exclusivo para seu perfil';

  @override
  String get shopItemTitleShadowHackerName => 'Título: Hacker das Sombras';

  @override
  String get shopItemTitleShadowHackerDesc => 'Título épico para seu perfil';

  @override
  String get shopItemTitleNightGuardianName => 'Título: Guardião Noturno';

  @override
  String get shopItemTitleNightGuardianDesc =>
      'Título exclusivo para seu perfil';

  @override
  String get shopItemTitleDigitalPhoenixName => 'Título: Fênix Digital';

  @override
  String get shopItemTitleDigitalPhoenixDesc =>
      'Título lendário para seu perfil';

  @override
  String get shopItemEffectDigitalRainName => 'Efeito: Chuva Digital';

  @override
  String get shopItemEffectDigitalRainDesc => 'Efeito de chuva Matrix animado';

  @override
  String get shopItemEffectFireTrailName => 'Efeito: Rastro de Fogo';

  @override
  String get shopItemEffectFireTrailDesc => 'Efeito de rastro de fogo animado';

  @override
  String get shopItemThemeBlueName => 'Tema Azul Profundo';

  @override
  String get shopItemThemeBlueDesc => 'Aparência azul premium';

  @override
  String get shopItemThemePurpleName => 'Tema Roxo';

  @override
  String get shopItemThemePurpleDesc => 'Aparência roxa premium';

  @override
  String get shopItemThemeDarkFireName => 'Tema Fogo Escuro';

  @override
  String get shopItemThemeDarkFireDesc => 'Tema de efeitos de fogo escuro';

  @override
  String get shopItemThemeCyberNeonName => 'Tema Neon Cibernético';

  @override
  String get shopItemThemeCyberNeonDesc => 'Tema neon futurista';

  @override
  String get mission3QueriesTitle => '3 Consultas';

  @override
  String get mission3QueriesDesc =>
      'Fale com Sage 3 vezes sobre diferentes assuntos.';

  @override
  String get missionConstantProtectorTitle => 'Protetor Constante';

  @override
  String get missionConstantProtectorDesc => 'Complete 3 lições hoje.';

  @override
  String get sageChipWhatIsPhishing => 'O que é phishing?';

  @override
  String get sageChipCreateStrongPassword => 'Criar senha forte';

  @override
  String get sageChipIdentifyScam => 'Identificar um golpe';
}
