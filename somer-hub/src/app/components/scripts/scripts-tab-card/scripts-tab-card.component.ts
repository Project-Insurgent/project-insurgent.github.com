import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Resource } from '../../../Utils/Resource';

@Component({
  selector: 'app-scripts-tab-card',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './scripts-tab-card.component.html',
  styleUrls: ['./scripts-tab-card.component.scss']
})
export class ScriptsTabCardComponent {
  @Input() rsc: Resource | undefined;
}
