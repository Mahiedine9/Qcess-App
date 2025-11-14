package univ.lille.infrastructure.adapter.messaging;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import univ.lille.domain.port.out.EmailPort;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailPortAdapter implements EmailPort {

    private final JavaMailSender javaMailSender;

    @Value("${app.mail.from}")
    private String fromEmail;

    @Value("${app.mail.fromName}")
    private String fromName;

    @Override
    public void sendWelcomeEmail(String to, String firstName, String loginCode) {
        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(to);
            helper.setSubject("🎉 Bienvenue sur Platine QCess - Votre code d'accès");

            String htmlContent = buildWelcomeEmailTemplate(firstName, loginCode);
            helper.setText(htmlContent, true);

            javaMailSender.send(message);
            log.info("✅ Email de bienvenue envoyé à : {}", to);

        } catch (MessagingException e) {
            log.error("❌ Erreur lors de l'envoi de l'email à : {}", to, e);
            throw new RuntimeException("Erreur lors de l'envoi de l'email", e);
        } catch (Exception e) {
            log.error("❌ Erreur inattendue lors de l'envoi de l'email", e);
            throw new RuntimeException("Erreur lors de l'envoi de l'email", e);
        }
    }

    @Override
    public void sendAdminWelcomeEmail(String to, String fullName, String organizationName) {
        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(to);
            helper.setSubject("👨‍💼 Compte Administrateur Activé - Platine QCess");

            String htmlContent = buildAdminWelcomeEmailTemplate(fullName, organizationName);
            helper.setText(htmlContent, true);

            javaMailSender.send(message);
            log.info("✅ Email administrateur envoyé à : {}", to);

        } catch (MessagingException e) {
            log.error("❌ Erreur lors de l'envoi de l'email admin à : {}", to, e);
            throw new RuntimeException("Erreur lors de l'envoi de l'email", e);
        } catch (Exception e) {
            log.error("❌ Erreur inattendue lors de l'envoi de l'email", e);
            throw new RuntimeException("Erreur lors de l'envoi de l'email", e);
        }
    }

    /**
     * Template HTML moderne pour l'email de bienvenue utilisateur
     */
    private String buildWelcomeEmailTemplate(String firstName, String loginCode) {
        return """
            <!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Bienvenue sur Platine QCess</title>
            </head>
            <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
                <table role="presentation" style="width: 100%%; background-color: #f4f7fa; padding: 40px 0;">
                    <tr>
                        <td align="center">
                            <!-- Container principal -->
                            <table role="presentation" style="max-width: 600px; width: 100%%; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08);">
                                
                                <!-- Header avec gradient -->
                                <tr>
                                    <td style="background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%; padding: 50px 40px; text-align: center;">
                                        <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: 700; text-shadow: 0 2px 4px rgba(0,0,0,0.2);">
                                            🏢 Platine QCess
                                        </h1>
                                        <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 16px; opacity: 0.95;">
                                            Gestion Intelligente de Bâtiments
                                        </p>
                                    </td>
                                </tr>
                                
                                <!-- Corps du message -->
                                <tr>
                                    <td style="padding: 40px;">
                                        <h2 style="color: #2d3748; margin: 0 0 20px 0; font-size: 24px;">
                                            Bonjour <span style="color: #667eea;">%s</span> 👋
                                        </h2>
                                        
                                        <p style="color: #4a5568; line-height: 1.6; margin: 0 0 25px 0; font-size: 16px;">
                                            Bienvenue dans votre espace Platine QCess ! Votre compte a été créé avec succès.
                                        </p>
                                        
                                        <p style="color: #4a5568; line-height: 1.6; margin: 0 0 30px 0; font-size: 16px;">
                                            Voici votre <strong>code d'accès personnel</strong> pour vous connecter à l'application mobile :
                                        </p>
                                        
                                        <!-- Code box avec effet glassmorphism -->
                                        <div style="background: linear-gradient(135deg, #667eea15 0%%, #764ba215 100%%); border: 2px solid #667eea; border-radius: 12px; padding: 30px; text-align: center; margin: 0 0 30px 0; backdrop-filter: blur(10px);">
                                            <div style="color: #667eea; font-size: 14px; font-weight: 600; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 10px;">
                                                Votre Code d'Accès
                                            </div>
                                            <div style="color: #2d3748; font-size: 36px; font-weight: 700; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                                                %s
                                            </div>
                                        </div>
                                        
                                        <!-- Instructions -->
                                        <div style="background-color: #edf2f7; border-left: 4px solid #667eea; border-radius: 8px; padding: 20px; margin: 0 0 30px 0;">
                                            <p style="color: #2d3748; margin: 0 0 12px 0; font-size: 15px; font-weight: 600;">
                                                📱 Comment vous connecter ?
                                            </p>
                                            <ol style="color: #4a5568; margin: 0; padding-left: 20px; line-height: 1.8;">
                                                <li>Téléchargez l'application Platine QCess</li>
                                                <li>Saisissez votre code d'accès</li>
                                                <li>Accédez à tous vos services</li>
                                            </ol>
                                        </div>
                                        
                                        <!-- Alerte sécurité -->
                                        <div style="background-color: #fff5f5; border: 1px solid #feb2b2; border-radius: 8px; padding: 15px; margin: 0 0 30px 0;">
                                            <p style="color: #c53030; margin: 0; font-size: 14px; line-height: 1.6;">
                                                <strong>⚠️ Important :</strong> Conservez ce code en lieu sûr et ne le partagez avec personne. Ce code vous est personnel.
                                            </p>
                                        </div>
                                        
                                        <!-- Fonctionnalités -->
                                        <div style="background: linear-gradient(to right, #f7fafc, #edf2f7); border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                            <h3 style="color: #2d3748; margin: 0 0 20px 0; font-size: 18px;">
                                                ✨ Ce que vous pouvez faire :
                                            </h3>
                                            <table role="presentation" style="width: 100%%;">
                                                <tr>
                                                    <td style="padding: 8px 0; color: #4a5568; font-size: 15px;">
                                                        🔐 <strong>Accès sécurisé</strong> par QR Code
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 8px 0; color: #4a5568; font-size: 15px;">
                                                        📢 <strong>Annonces</strong> de votre organisation
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 8px 0; color: #4a5568; font-size: 15px;">
                                                        🔧 <strong>Signaler</strong> des incidents
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 8px 0; color: #4a5568; font-size: 15px;">
                                                        📅 <strong>Réserver</strong> des salles
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 8px 0; color: #4a5568; font-size: 15px;">
                                                        📦 <strong>Gérer</strong> vos colis
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        
                                        <p style="color: #718096; font-size: 14px; margin: 0; line-height: 1.6;">
                                            Besoin d'aide ? Contactez votre administrateur ou consultez notre guide d'utilisation.
                                        </p>
                                    </td>
                                </tr>
                                
                                <!-- Footer -->
                                <tr>
                                    <td style="background-color: #f7fafc; padding: 30px; text-align: center; border-top: 1px solid #e2e8f0;">
                                        <p style="color: #a0aec0; font-size: 13px; margin: 0 0 8px 0;">
                                            Cet email a été envoyé automatiquement, merci de ne pas y répondre.
                                        </p>
                                        <p style="color: #a0aec0; font-size: 13px; margin: 0;">
                                            © 2025 <strong>Platine QCess</strong> - Tous droits réservés
                                        </p>
                                        <div style="margin-top: 15px;">
                                            <span style="display: inline-block; margin: 0 5px; color: #cbd5e0; font-size: 12px;">🏢</span>
                                            <span style="display: inline-block; margin: 0 5px; color: #cbd5e0; font-size: 12px;">🔒</span>
                                            <span style="display: inline-block; margin: 0 5px; color: #cbd5e0; font-size: 12px;">📱</span>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </body>
            </html>
            """.formatted(firstName, loginCode);
    }

    /**
     * Template HTML moderne pour l'email administrateur
     */
    private String buildAdminWelcomeEmailTemplate(String fullName, String organizationName) {
        return """
            <!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Compte Administrateur Activé</title>
            </head>
            <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
                <table role="presentation" style="width: 100%%; background-color: #f4f7fa; padding: 40px 0;">
                    <tr>
                        <td align="center">
                            <table role="presentation" style="max-width: 600px; width: 100%%; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08);">
                                
                                <!-- Header Administrateur -->
                                <tr>
                                    <td style="background: linear-gradient(135deg, #1e3a8a 0%%, #3b82f6 100%%); padding: 50px 40px; text-align: center;">
                                        <div style="font-size: 48px; margin-bottom: 15px;">👨‍💼</div>
                                        <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: 700;">
                                            Compte Administrateur
                                        </h1>
                                        <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 16px; opacity: 0.95;">
                                            Platine QCess - Espace Administration
                                        </p>
                                    </td>
                                </tr>
                                
                                <!-- Corps -->
                                <tr>
                                    <td style="padding: 40px;">
                                        <h2 style="color: #2d3748; margin: 0 0 20px 0; font-size: 24px;">
                                            Bonjour <span style="color: #3b82f6;">%s</span> 👋
                                        </h2>
                                        
                                        <p style="color: #4a5568; line-height: 1.6; margin: 0 0 25px 0; font-size: 16px;">
                                            Félicitations ! Votre compte administrateur a été créé avec succès.
                                        </p>
                                        
                                        <!-- Info Organisation -->
                                        <div style="background: linear-gradient(135deg, #3b82f615 0%%, #1e3a8a15 100%%); border: 2px solid #3b82f6; border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                            <div style="color: #3b82f6; font-size: 14px; font-weight: 600; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 15px;">
                                                🏢 Votre Organisation
                                            </div>
                                            <div style="color: #2d3748; font-size: 24px; font-weight: 700;">
                                                %s
                                            </div>
                                        </div>
                                        
                                        <!-- Accès plateforme -->
                                        <div style="background-color: #eff6ff; border-left: 4px solid #3b82f6; border-radius: 8px; padding: 20px; margin: 0 0 30px 0;">
                                            <p style="color: #2d3748; margin: 0 0 12px 0; font-size: 15px; font-weight: 600;">
                                                🌐 Accès à la plateforme
                                            </p>
                                            <p style="color: #4a5568; margin: 0; line-height: 1.6; font-size: 15px;">
                                                Vous pouvez maintenant vous connecter à la <strong>plateforme web d'administration</strong> avec vos identifiants (email et mot de passe).
                                            </p>
                                        </div>
                                        
                                        <!-- Fonctionnalités Admin -->
                                        <div style="background: linear-gradient(to right, #f0fdf4, #dcfce7); border-radius: 12px; padding: 25px; margin: 0 0 30px 0;">
                                            <h3 style="color: #2d3748; margin: 0 0 20px 0; font-size: 18px;">
                                                ⚡ Vos Privilèges Administrateur
                                            </h3>
                                            <table role="presentation" style="width: 100%%;">
                                                <tr>
                                                    <td style="padding: 10px 0; color: #4a5568; font-size: 15px;">
                                                        👥 <strong>Gestion des utilisateurs</strong>
                                                        <div style="color: #718096; font-size: 13px; margin-top: 4px;">Créer, modifier, désactiver des comptes</div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 10px 0; color: #4a5568; font-size: 15px;">
                                                        🎛️ <strong>Configuration des modules</strong>
                                                        <div style="color: #718096; font-size: 13px; margin-top: 4px;">Activer/désactiver les fonctionnalités</div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 10px 0; color: #4a5568; font-size: 15px;">
                                                        🔐 <strong>Contrôle d'accès QR</strong>
                                                        <div style="color: #718096; font-size: 13px; margin-top: 4px;">Gérer les zones et permissions</div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 10px 0; color: #4a5568; font-size: 15px;">
                                                        🔧 <strong>Suivi des incidents</strong>
                                                        <div style="color: #718096; font-size: 13px; margin-top: 4px;">Traiter les demandes de maintenance</div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 10px 0; color: #4a5568; font-size: 15px;">
                                                        📊 <strong>Tableaux de bord</strong>
                                                        <div style="color: #718096; font-size: 13px; margin-top: 4px;">Statistiques et rapports détaillés</div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 10px 0; color: #4a5568; font-size: 15px;">
                                                        📅 <strong>Gestion des réservations</strong>
                                                        <div style="color: #718096; font-size: 13px; margin-top: 4px;">Salles, équipements, ressources</div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        
                                        <!-- Prochaines étapes -->
                                        <div style="background-color: #fefce8; border: 1px solid #fde047; border-radius: 8px; padding: 20px; margin: 0 0 20px 0;">
                                            <p style="color: #854d0e; margin: 0 0 12px 0; font-size: 15px; font-weight: 600;">
                                                🚀 Prochaines étapes
                                            </p>
                                            <ol style="color: #713f12; margin: 0; padding-left: 20px; line-height: 1.8; font-size: 14px;">
                                                <li>Connectez-vous à la plateforme web</li>
                                                <li>Complétez les informations de votre organisation</li>
                                                <li>Créez vos premiers utilisateurs</li>
                                                <li>Configurez les modules selon vos besoins</li>
                                            </ol>
                                        </div>
                                        
                                        <p style="color: #718096; font-size: 14px; margin: 0; line-height: 1.6;">
                                            Pour toute question, consultez notre <strong>documentation</strong> ou contactez le support technique.
                                        </p>
                                    </td>
                                </tr>
                                
                                <!-- Footer -->
                                <tr>
                                    <td style="background-color: #f7fafc; padding: 30px; text-align: center; border-top: 1px solid #e2e8f0;">
                                        <p style="color: #a0aec0; font-size: 13px; margin: 0 0 8px 0;">
                                            Cet email a été envoyé automatiquement, merci de ne pas y répondre.
                                        </p>
                                        <p style="color: #a0aec0; font-size: 13px; margin: 0;">
                                            © 2025 <strong>Platine QCess</strong> - Tous droits réservés
                                        </p>
                                        <div style="margin-top: 15px;">
                                            <span style="display: inline-block; margin: 0 5px; color: #cbd5e0; font-size: 12px;">👨‍💼</span>
                                            <span style="display: inline-block; margin: 0 5px; color: #cbd5e0; font-size: 12px;">🔒</span>
                                            <span style="display: inline-block; margin: 0 5px; color: #cbd5e0; font-size: 12px;">⚡</span>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </body>
            </html>
            """.formatted(fullName, organizationName);
    }
}