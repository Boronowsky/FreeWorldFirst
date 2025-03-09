#!/bin/bash
set -e

echo "🔧 Behebe JWT-Strategie-Problem..."

cd ../FreeWorldFirst/backend

# JWT-Strategie korrigieren
cat > src/auth/strategies/jwt.strategy.ts << 'EOF2'
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    // Sicherstellen, dass immer ein String verwendet wird
    const secretKey = configService.get<string>('JWT_SECRET');
    
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: secretKey || 'fallback-secret-key',
    });
  }

  async validate(payload: any) {
    return { userId: payload.sub, username: payload.username };
  }
}
EOF2

# Helmet-Anpassung überprüfen
if grep -q "app.use(helmet())" src/main.ts; then
  echo "Korrigiere Helmet-Aufruf in main.ts"
  sed -i 's/app.use(helmet())/app.use(helmet.default())/' src/main.ts
fi

echo "✅ JWT-Strategie-Problem erfolgreich behoben!"
